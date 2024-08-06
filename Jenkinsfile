pipeline{
    environment {
        INAGE_NAME ="website_img"
        INAGE_TAG ="latest"
        STAGING = "olivierdja-website-staging"
        PRODUCTION = "olivierdja-website-prod"
        ENDPOINT="http://3.95.66.11"
        DOCKERHUB_CREDENTIALS = credentials('dockerhub_passowrd')
    }
    agent none
    stages{
        stage('Build Docker Image'){
            agent any
            steps{
                script {
                    sh 'docker build -t olivierdja/$INAGE_NAME:$INAGE_TAG .' 
                }
            }
        }

        stage('Launch Docker Container'){
            agent any
            steps{
                script {
                    '''bash
                    docker run --name=$INAGE_NAME -dp 83:80 -e PORT=80 olivierdja/$INAGE_NAME:$INAGE_TAG
                    sleep 5
                    
                    '''
                }
            }
        }

        stage('Run Tests'){
            agent any
            steps{
                script {
                    sh '''
                    curl $ENDPOINT:83 | grep "Dimension"
                    
                    '''
                }
            }
        }
        stage('Clean Up Existing Containers'){
            agent any
            steps{
                script {
                    sh '''
                    docker rm -f $INAGE_NAME || echo "Container does not exist"
                    
                    '''
                }
            }
        }

        stage('Upload Image to DockerHub'){
            agent any
            steps{
                script {
                    sh '''
                    echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
                    docker push  olivierdja/$INAGE_NAME:latest
            
                    '''
                }
            }
        }
        stage('Deploy to Heroku Staging'){
            when{
                expression { GIT_BRANCH == 'origin/master'}
            }
            agent any
            environment{
                HEROKU_API_KEY = credentials('heroku_api_key')
            }
            steps{
                script {
                    sh '''
                    npm i -g heroku@7.68.0
                    heroku container:login
                    heroku create $STAGING || echo "project already exist"
                    heroku container:push -a $STAGING web
                    heroku container:release -a $STAGING web
                    
                    '''
                }
            }
        }
        stage('Deploy to Heroku Production'){
            when{
                expression { GIT_BRANCH == 'origin/master'}
            }
            agent any
            environment{
                HEROKU_API_KEY = credentials('heroku_api_key')
            }
            steps{
                script {
                    sh '''
                  npm i -g heroku@7.68.0
                  heroku container:login
                  heroku create $PRODUCTION || echo "project already exist"
                  heroku container:push -a $PRODUCTION web
                  heroku container:release -a $PRODUCTION web
                    
                    '''
                }
            }
        }
    }
}
