# Simple Recommender System using BigQuery


This is a demo project to show you how you can use BigQuery strength points to process BigData within seconds/minutes level.

I used PHP script to generate random data, and used gcloud CLI to connect to BigQuery for creating new dataset, creating tables and importing data.


# Requirements

  - GCP account, you can get free credits once you [signup](https://cloud.google.com/gcp)
  - Install gcloud and login to your account, [gcloud](https://cloud.google.com/sdk/gcloud)
  - Create new GCP project, create/get a project ID
  - ```sh
    export GCP_ID=YOUR_PROJECT_ID
    export GCP_BQ_DATA_LOCATION=YOUR_PREFERRED_LOCATION #US
    ./commands.sh #create new dataset in BQ, create and import required tables
    ```
 - use https://console.cloud.google.com/bigquery web console to run the query in query.sql, so you can preview results debug the query
    
You can refer to my article on Medium to understand how this example works, See [Recommend personalised content for your app users using BigQuery](https://medium.com/@abdulrahmanbabil/recommend-personalised-content-for-your-app-users-using-bigquery-239b1398a46a).

