pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
metadata:
  labels:
    component: jenkins-agent
spec:
  containers:
  - name: maven
    image: docker.io/library/maven:3.9.6-eclipse-temurin-17
    command: ['cat']
    tty: true
  - name: kaniko
    image: gcr.io/kaniko-project/executor:v1.23.0-debug
    command: ['/busybox/cat']
    tty: true
  - name: jnlp
    image: docker.io/jenkins/inbound-agent:3355.v388858a_47b_33-3-jdk21
'''
        }
    }

    environment {
        HARBOR_REGISTRY = 'ingress-lab.search.tec.br'
        PROJECT_NAME    = 'tarefa'
        APP_NAME        = 'app-tarefa'
        IMAGE_TAG       = "${BUILD_NUMBER}"
        
        HARBOR_CRED_ID  = 'harbor-registry-credentials'
        GITHUB_CRED_ID  = 'github-pat-jenkins'
    }

    stages {
        stage('Build Java (Maven)') {
            steps {
                container('maven') {
                    echo 'Iniciando a compilação do projeto Java...'
                    sh 'mvn clean package -DskipTests'
                }
            }
        }

        stage('Build & Push Imagem (Kaniko)') {
            steps {
                container('kaniko') {
                    echo 'Iniciando a construção da imagem com o Kaniko...'
                    
                    sh '/busybox/mkdir -p /kaniko/.docker'
                    
                    withCredentials([usernamePassword(credentialsId: "${HARBOR_CRED_ID}", usernameVariable: 'REGISTRY_USER', passwordVariable: 'REGISTRY_PASSWORD')]) {
                        sh """
                        echo '{"auths":{"${HARBOR_REGISTRY}":{"username":"${REGISTRY_USER}","password":"${REGISTRY_PASSWORD}"}}}' > /kaniko/.docker/config.json
                        """
                    }
                    
                    sh """
                    /kaniko/executor --context=${WORKSPACE} \
                                     --dockerfile=${WORKSPACE}/Dockerfile \
                                     --destination=${HARBOR_REGISTRY}/${PROJECT_NAME}/${APP_NAME}:${IMAGE_TAG}
                    """
                }
            }
        }
    }
}