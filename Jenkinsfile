pipeline {
    agent any
    
    environment {
        SCANNER_HOME= tool 'sonar-scanner'                      
        
        /// THIS IS FOR DOCKER CRED TO PUSH 
        APP_NAME = "sbs-webapp"      
        RELEASE = "1.0.0"
        DOCKER_USER = "raemondarellano"
        DOCKER_PASS = 'jenkins-docker-credentials'              
        IMAGE_NAME = "${DOCKER_USER}" + "/" + "${APP_NAME}"  
        IMAGE_TAG = "${RELEASE}-${BUILD_NUMBER}"
        JENKINS_API_TOKEN = credentials("JENKINS_API_TOKEN")
        
    }
    stages{
        stage("Cleanup Workspace"){
                steps {
                cleanWs()
                }
        }

        stage("Checkout from SCM"){
                steps {
                    git branch: 'main', credentialsId: 'github', url: 'https://github.com/iam-arellano/sbs-webapp.git'
                    echo 'Git Checkout Completed'
                }
        }


        stage ('DEV Approve') {                 //aproval before proceed
             steps {
                echo "Taking approval from DEV Manager for QA Deployment"
                timeout(time: 7, unit: 'DAYS') {
                input message: 'Do you want to deploy?', submitter: 'admin'
              }
            }
        }

        stage("Build & Push Docker Image") {
            steps {
                script {
                    docker.withRegistry('',DOCKER_PASS) {
                        docker_image = docker.build "${IMAGE_NAME}"
                    }

                    docker.withRegistry('',DOCKER_PASS) {
                        docker_image.push("${IMAGE_TAG}")
                        docker_image.push('latest')
                    }
                }
            }
       }
   //  to scan docker image 
        stage("Trivy Scan") {
           steps {
               script {
	            sh ('docker run -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image raemondarellano/sbs-webapp:latest --no-progress --scanners vuln  --exit-code 0 --severity HIGH,CRITICAL --format table')
               }
           }
       }
       
        stage ('Cleanup Artifacts') {
           steps {
               script {
                    sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG}"
                    sh "docker rmi ${IMAGE_NAME}:latest"
               }
          }
        }

        // Update Deployment yaml
         stage("Update the Deployment Tags") {
            steps {
                sh """
                   cat deployment.yaml
                   sed -i 's/${APP_NAME}.*/${APP_NAME}:${IMAGE_TAG}/g' deployment.yaml
                   cat deployment.yaml
                """
                 }
             }

     }
}