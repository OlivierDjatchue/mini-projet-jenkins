pipeline{
    environment {
        INAGE_NAME ="Static_Website"
        INAGE_TAG ="latest"
        STAGING = "Static_Website-staging"
        PRODUCTION = "Static_Website-prod"
    }
    agent none
    stages{
        stage('Build image'){
            agent any
            steps{
                script {
                    sh 'docker build -t olivierdja/$INAGE_NAME:$INAGE_NAME .' 
                }
            }
        }
        stage('Delete container if exist'){
            agent any
            steps{
                script {
                    sh '''
                    docker rm -f $INAGE_NAME || echo "Container does not exist"
                    
                    '''
                }
            }
        }
        stage('Run container'){
            agent any
            steps{
                script {
                    sh '''
                    docker run --name=$INAGE_NAME -dp 83:80 -e PORT=80 olivierdja/$INAGE_NAME:$INAGE_NAME
                    sleep 5
                    
                    '''
                }
            }
        }

        stage('Test image'){
            agent any
            steps{
                script {
                    sh '''
// change the URL with the URL of your VM
                    curl http://54.227.75.184 || grep "Adipiscing magna sed dolor elit."  
                    sleep 5
                    
                    '''
                }
            }
        }
        stage('Clean container'){
            agent any
            steps{
                script {
                    sh '''
                    docker stop $INAGE_NAME
                    docker rm $INAGE_NAME
                    '''
                }
            }
        }
        stage('push imahe in staging and deploy'){
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
        stage('push imahe in PRODUCTION and deploy'){
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