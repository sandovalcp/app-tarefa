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
    image: maven:3.9.6-eclipse-temurin-17
    command: ['cat']
    tty: true
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command: ['cat']
    tty: true
    volumeMounts:
    - name: harbor-auth
      mountPath: /kaniko/.docker
  volumes:
  - name: harbor-auth
    secret:
      secretName: harbor-registry-secret
'''
        }
    }

    environment {
        // Altere para o domínio correto do seu Harbor
        HARBOR_REGISTRY = 'ingress-lab.search.tec.br'
        PROJECT_NAME    = 'tarefa'
        APP_NAME        = 'app-tarefa'
        IMAGE_TAG       = "${BUILD_NUMBER}"
        
        // IDs das credenciais que cadastramos na interface do Jenkins
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
                    
                    // O Kaniko utiliza o arquivo config.json gerado pelas credenciais do Jenkins
                    withCredentials([usernamePassword(credentialsId: "${HARBOR_CRED_ID}", usernameVariable: 'REGISTRY_USER', passwordVariable: 'REGISTRY_PASSWORD')]) {
                        sh """
                        echo '{"auths":{"${HARBOR_REGISTRY}":{"username":"${REGISTRY_USER}","password":"${REGISTRY_PASSWORD}"}}}' > /kaniko/.docker/config.json
                        """
                    }
                    
                    // Executa o build do Dockerfile e o push para o Harbor
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
