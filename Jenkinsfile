 
pipeline {
    environment {
        registry = "rakeshkadam/capstone"
        registryCredential = 'dockerhub'
        dockerImage = ''
    }
    agent any
    stages {

		    stage('Lint HTML') {
			    steps {
				    sh 'tidy -q -e *.html'
				    sh 'echo $USER'
			    }
		    }
        
        
            stage('Building image') {
                steps{
                script {
                    dockerImage = docker.build registry + ":$BUILD_NUMBER"
                    }
                }
            }

            stage('Deploy Image') {
                steps{
                script {
                    docker.withRegistry( '', registryCredential ) {
                    dockerImage.push()
                        }
                    }
                }
            }

            stage('Configure and Build Kubernetes Cluster'){
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    sh 'ansible-playbook ./playbooks/create-cluster.yml'
                    }
                }
            }

            stage('Set current kubectl context') {
			steps {
				withAWS(region:'ap-south-1', credentials:'eks_cluster') {
					sh '''
						kubectl config use-context arn:aws:eks:ap-south-1:157746943235:cluster/capstone-project
					'''
				}
			}
		}

		stage('Deploy blue container') {
			steps {
				withAWS(region:'ap-south-1', credentials:'eks_cluster') {
					sh '''
						kubectl apply -f ./blue-controller.json
					'''
				}
			}
		}

		stage('Deploy green container') {
			steps {
				withAWS(region:'ap-south-1', credentials:'eks_cluster') {
					sh '''
						kubectl apply -f ./green-controller.json
					'''
				}
			}
		}

		stage('Create the service in the cluster, redirect to blue') {
			steps {
				withAWS(region:'ap-south-1', credentials:'eks_cluster') {
					sh '''
						kubectl apply -f ./blue-service.json
					'''
				}
			}
		}

		stage('Wait user approve') {
            steps {
                input "Ready to redirect traffic to green?"
            }
        }

		stage('Create the service in the cluster, redirect to green') {
			steps {
				withAWS(region:'ap-south-1', credentials:'eks_cluster') {
					sh '''
						kubectl apply -f ./green-service.json
					'''
				}
			}
		}
    }
}