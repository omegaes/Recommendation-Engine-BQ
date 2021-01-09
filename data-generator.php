<?php



$users = readCsvFile("data/user.csv");
$articles  = readCsvFile("data/article.csv");
$topics = readCsvFile("data/topic.csv");
$publishers = readCsvFile("data/publisher.csv");



generateUserReleationArticles($users, $articles,"data/user_article_read.csv", 4);
generateUserReleationArticles($users, $articles,"data/user_article_feed.csv", 3);
generateUserDimensionRelevance($users, $topics,"topic", "data/user_topic.csv");
generateUserDimensionRelevance($users, $publishers,"publisher", "data/user_publisher.csv");


function generateUserReleationArticles(&$users, &$articles, $fileName, $maximumPercent = 3){
    $userReadArticles = [];
    $userReadArticles[] = ["user_id", "article_id"];
    foreach($users as $user){
        $totalReadedArticles = rand(0, count($articles)/$maximumPercent);
        while($totalReadedArticles > 0){
            $randomArticleIndex = rand(0, count($articles)-1);
            $userReadArticles[] = [
                $user['id'], $articles[$randomArticleIndex]['id']
            ];
            $totalReadedArticles--;
        }
    }

    writeCsvFile($fileName, $userReadArticles);
}

function generateUserDimensionRelevance(&$users, &$dimensions, $dimensionName, $fileName){
    $userDimensionsRelevance = [];
    $userDimensionsRelevance[] = ["user_id", "{$dimensionName}_id","relevance"];
    foreach($users as $user){
        foreach($dimensions as $dimension){
            $userDimensionsRelevance[] = [
                $user['id'],$dimension['id'], rand(0,10) /10
            ];
        }
        
    }

    writeCsvFile($fileName, $userDimensionsRelevance);
}



function readCsvFile($filePath)
{
    $file = fopen($filePath,"r");
    $fields = [];
    $rows = [];
    $firstLine = false;
    while(($row = fgetcsv($file)) !== false)
    {
        if(!$firstLine){
            $firstLine = true;
            $fields = $row;
            continue;
        }
        $newRow = [];
        foreach($row as $index => $value){
            $newRow[$fields[$index]] = trim($value);
        }
        $rows[] = $newRow;
    }
    fclose($file);
    return $rows;
}


function writeCsvFile($filePath, $rows){
    $fp = fopen($filePath, 'w');
    foreach($rows as $row){
        fputcsv($fp, $row);
    }
    fclose($fp);
}