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
  - name: jnlp
    image: docker.io/jenkins/inbound-agent:3355.v388858a_47b_33-3-jdk21
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
                    sh '''
                    /kaniko/executor \
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
                echo "Atualizando repositório de CD com a tag ${BUILD_NUMBER}..."
            }
        }
    }
}