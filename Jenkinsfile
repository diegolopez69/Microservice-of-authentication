pipeline {
    agent any
        environment {
            //SSH_PASS = credentials('ssh-pass-bifrost')
            //DEPLOY_DIR = "~/orbis-api-deploy"
            APP_NAME = "orbis-api"
            //NAMESPACE = "interstellar"
        }
    stages{    
        stage('Build') {
            steps {
                echo '==== BUILDING STAGE ===='
                dir('src') {
                    configFileProvider([configFile(fileId: '4055cc6d-fc5c-4c88-a477-c8d43ea9751d', targetLocation: '.env', variable: 'newenv')]) {
                    }

                    sh 'composer install'
                }
                
            }
        }


        stage('Deploy') {
            steps { 
                echo '==== DEPLOYING STAGE ===='
                //Add secrets file
                configFileProvider([configFile(fileId: 'f6ad9bab-e503-4bd2-b449-d70fbc1c3263', targetLocation: 'etc/kubernetes/secret.yml', variable: 'newsecret')]) {
                        
                }
                sh 'docker build . -t ${APP_NAME}:${BUILD_ID}'
                sh 'docker tag ${APP_NAME}:${BUILD_ID} 172.22.4.25:5000/${APP_NAME}:${BUILD_ID}'
                sh 'docker push 172.22.4.25:5000/${APP_NAME}:${BUILD_ID}'
                sh 'docker rm -f ${APP_NAME}||true'
                sh 'docker run -dit --restart always -p 8101:8080 --name ${APP_NAME} ${APP_NAME}:${BUILD_ID}'
                
                // sh 'sshpass -p "${SSH_PASS}" ssh -o StrictHostKeyChecking=no bifrost@172.22.5.4 "mkdir -p ${DEPLOY_DIR}"'
                // sh 'sshpass -p "${SSH_PASS}" scp -r etc/kubernetes/*.yml bifrost@172.22.5.4:${DEPLOY_DIR}'
                //sh 'sshpass -p "${SSH_PASS}" ssh -o StrictHostKeyChecking=no bifrost@172.22.5.4 "kubectl patch -f ${DEPLOY_DIR}/deployment.yml -p \'{\"spec\":{\"template\":{\"spec\":{\"containers\":[{\"image\":\"172.22.4.25:5000/${APP_NAME}:${BUILD_ID}\"}]}}}}\'"'
                // sh 'sshpass -p "${SSH_PASS}" ssh -o StrictHostKeyChecking=no bifrost@172.22.5.4 "kubectl -n ${NAMESPACE} apply -f ${DEPLOY_DIR} -R"'
                // sh 'sshpass -p "${SSH_PASS}" ssh -o StrictHostKeyChecking=no bifrost@172.22.5.4 "kubectl -n ${NAMESPACE} --record deployment.apps/${APP_NAME} set image deployment.v1.apps/${APP_NAME} ${APP_NAME}=172.22.4.25:5000/${APP_NAME}:${BUILD_ID}"'
            }
        }

    }
    
    post {
    
        always {
            gitlabCommitStatus('jenkins') {
                // some block
            }
        }
        success{
            updateGitlabCommitStatus name: 'jenkins', state:'success'
            slackSend channel: '#orbis-builds', color: 'good', message: "${JOB_NAME} build  #${BUILD_NUMBER} succeeded (<${RUN_DISPLAY_URL}|Open>)", tokenCredentialId: 'slack'
        }
        failure{
            updateGitlabCommitStatus name: 'jenkins', state:'failed'
            slackSend channel: '#orbis-builds', color: 'danger', message: "${JOB_NAME} build  #${BUILD_NUMBER} failed (<${RUN_DISPLAY_URL}|Open>) :pepehands:", tokenCredentialId: 'slack'
        }
    }

    
}

