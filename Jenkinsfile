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
        
        // CORREÇÃO/ADICIONAL: URL do seu repositório de CD (ajuste o nome do repositório se necessário)
        CD_REPO_URL     = 'github.com/sandovalcp/app-tarefa-cd.git'
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
                                     --destination=${HARBOR_REGISTRY}/${PROJECT_NAME}/${APP_NAME}:${IMAGE_TAG} \
                                     --skip-tls-verify
                    """
                }
            }
        }

        stage('Push Helm Chart to CD Repo') {
            steps {
                container('maven') {
                    echo 'Iniciando a sincronização do Helm Chart com o repositório de CD...'
                    
                    withCredentials([usernamePassword(credentialsId: "${GITHUB_CRED_ID}", usernameVariable: 'GIT_USER', passwordVariable: 'GIT_TOKEN')]) {
                        sh """
                        # Configuração de identidade do Git para o commit
                        git config --global user.email "jenkins@search.tec.br"
                        git config --global user.name "Jenkins CI"
                        
                        # Altera estritamente a tag da imagem no values.yaml local antes de enviar
                        # Altera o repository para apontar para o seu Harbor e atualiza a tag dinâmica do Build
                        sed -i "s|repository:.*|repository: ${HARBOR_REGISTRY}/${PROJECT_NAME}/${APP_NAME}|g" values.yaml
                        sed -i "s|tag:.*|tag: ${IMAGE_TAG}|g" values.yaml
                        
                        # Cria uma pasta temporária isolada para clonagem do outro repositório
                        rm -rf tmp-cd-repo
                        mkdir tmp-cd-repo
                        
                        # Clona o repositório de CD usando a credencial injetada de forma segura
                        git clone https://${GIT_USER}:${GIT_TOKEN}@${CD_REPO_URL} tmp-cd-repo/
                        
                        # Cria a estrutura de pastas do Helm Chart dentro do repositório de CD se não existirem
                        mkdir -p tmp-cd-repo/chart/templates
                        
                        # Copia cirurgicamente apenas os arquivos alterados e necessários do Helm
                        cp Chart.yaml tmp-cd-repo/chart/
                        cp values.yaml tmp-cd-repo/chart/
                        cp deployment.yaml tmp-cd-repo/chart/templates/
                        cp ingress.yaml tmp-cd-repo/chart/templates/
                        cp service.yaml tmp-cd-repo/chart/templates/
                        cp networkpolicy.yaml tmp-cd-repo/chart/templates/
                        cp pdb.yaml tmp-cd-repo/chart/templates/
                        
                        # Entra no diretório clonado, adiciona os arquivos, faz commit e push
                        cd tmp-cd-repo
                        git add chart/
                        
                        # Só realiza o commit e push se houverem modificações reais nos arquivos
                        if ! git diff-index --quiet HEAD --; then
                            git commit -m "image bump: atualizando tag da imagem para b${IMAGE_TAG} [skip ci]"
                            git push origin main
                            echo "Repositório de CD atualizado com sucesso!"
                        else
                            echo "Nenhuma alteração detectada no Helm Chart. Ignorando push."
                        fi
                        """
                    }
                }
            }
        }
    }
}