with article as 
( 
  select * from test_data.article
),
user as (
  select * from test_data.user
),
topic as (
  select * from test_data.topic
),
user_read as (
  select * from `test_data.user_article_read` 
),
user_feed as (
  select * from `test_data.user_article_feed` 
),
user_publisher as (
  select * from test_data.user_publisher
),
user_topic as (
  select * from test_data.user_topic
),
enhanced_articles as (
  select *, 
  ROW_NUMBER() over (Partition BY article.topic_id ORDER BY score DESC ) as article_rank,
  max(score) over (Partition BY article.topic_id) as article_max_score,
  min(score) over (Partition BY article.topic_id) as article_min_score,
   1000 * (score / max(score) over (Partition BY article.topic_id)) as enhanced_score

  from article
),
user_article as (
  select user.id as user_id, article.id as article_id, article.score  as original_score, article.publisher_id , article.topic_id, article.enhanced_score  
  from user cross join enhanced_articles as article
),
user_article_with_dimension_relevance as (
  select user_article.*,  
  user_publisher.relevance as user_publisher_relevance,
  user_topic.relevance as user_topic_relevance
  from user_article 
  left join user_publisher on user_publisher.user_id = user_article.user_id  and user_article.publisher_id = user_publisher.publisher_id 
  left join user_topic on user_topic.user_id = user_article.user_id and user_topic.topic_id  = user_article.topic_id 
),
user_article_check_read_and_feed as (
  select distinct user_article_with_dimension_relevance.*, 
  IF(user_read.article_id is null, 0, 1) as read,
  IF(user_feed.article_id is null, 0, 1) as feed
  from user_article_with_dimension_relevance
  left join user_feed on user_feed.user_id = user_article_with_dimension_relevance.user_id and user_feed.article_id  = user_article_with_dimension_relevance.article_id
  left join user_read on user_read.user_id = user_article_with_dimension_relevance.user_id and user_read.article_id  = user_article_with_dimension_relevance.article_id
),
user_article_filtered as (

  select * from user_article_check_read_and_feed where read = 1 or feed = 1 or user_publisher_relevance = 0 or user_topic_relevance = 0
),
user_article_with_relevance_score as (
  select u.user_id, u.article_id, u.original_score, u.publisher_id, u.topic_id, ((user_publisher_relevance+user_topic_relevance)/2) as relevance_score, u.enhanced_score 
  from user_article_filtered as u 

),
user_article_with_calculated_score as (
   select *, (enhanced_score*relevance_score) user_article_relevance_score,
   ROW_NUMBER() over (Partition BY user_id ORDER BY (enhanced_score*relevance_score) DESC ) as user_article_rank,

   from user_article_with_relevance_score
),
user_with_top_articles as (
   select user_id, 
   to_json_string(ARRAY_AGG(
    STRUCT<article_id INT64, original_score INT64, publisher_id INT64, topic_id INT64, relevance_score FLOAT64, enhanced_score FLOAT64, user_article_relevance_score FLOAT64, user_article_rank INT64>(article_id,original_score,publisher_id, topic_id, relevance_score, enhanced_score, user_article_relevance_score, user_article_rank)
   ) ) data
   from user_article_with_calculated_score
   where user_article_rank <= 5
   group by user_id

)
 select * from user_with_top_articles 
