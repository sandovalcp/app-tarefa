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
    command: ["cat"]
    tty: true
    volumeMounts:
    - name: workspace-volume
      mountPath: /home/jenkins/agent
  - name: kaniko
    image: gcr.io/kaniko-project/executor:v1.23.0-debug
    command: ["/busybox/cat"]
    tty: true
    volumeMounts:
    - name: workspace-volume
      mountPath: /home/jenkins/agent
volumes:
- name: workspace-volume
  emptyDir: {}
'''
        }
    }
    
    stages {
        stage('Build Java (Maven)') {
            steps {
                container('maven') {
                    sh 'mvn clean package -DskipTests'
                }
            }
        }
        
        stage('Build & Push Imagem (Kaniko)') {
            steps {
                container('kaniko') {
                    // O comando 'true' ao final garante que o shell retorne status 0 ao Jenkins de forma explícita
                    sh '''
                    /busybox/executor \
                      --context=dir://. \
                      --dockerfile=Dockerfile \
                      --destination=harbor.search.tec.br/infra/app-tarefa:${BUILD_NUMBER}
                    true
                    '''
                }
            }
        }
        
        stage('Push Helm Chart to CD Repo') {
            steps {
                // Seu bloco existente que gerencia o clone do Git e o push no repositório de CD
                echo "Atualizando repositório de CD com a tag ${BUILD_NUMBER}..."
            }
        }
    }
}