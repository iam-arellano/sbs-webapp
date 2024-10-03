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



    //     stage("SonarQube Analysis"){
    //        steps {
	//            script {
	// 	        withSonarQubeEnv(credentialsId: 'sonarqube_access') { 
    //                     sh "sonar-sonar"
	// 	        }
	//            }	
    //        }
    //    }


    //      stage("Quality Gate"){
    //        steps {
    //            script {
    //                 waitForQualityGate abortPipeline: false, credentialsId: 'sonarqube_access'
    //             }	
    //         }

    //    }


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

            // Trigger gitops-calculator
        //   stage("Trigger CD Pipeline") {
        //     steps {
        //         script {
        //             sh "curl -v -k --user raemond:${JENKINS_API_TOKEN} -X POST -H 'cache-control: no-cache' -H 'content-type: application/x-www-form-urlencoded' --data 'IMAGE_TAG=${IMAGE_TAG}' 'http://192.168.100.151:8080/job/gitops-rms-app/buildWithParameters?token=gitops-token-rms'"
        //         }
        //     }
        // }

     }
}