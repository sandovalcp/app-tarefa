# ==========================================
# Etapa 1: Compilação da aplicação Java
# ==========================================
FROM maven:3.9.6-eclipse-temurin-17 AS builder
WORKDIR /app

# Copia o arquivo de definição de dependências
COPY pom.xml .

# Copia todo o código-fonte do projeto
COPY src ./src

# Executa o build do Maven gerando o arquivo .war final e pulando os testes unitários
RUN mvn clean package -DskipTests

# ==========================================
# Etapa 2: Imagem final leve para execução
# ==========================================
FROM tomcat:10.1-jdk17-temurin
WORKDIR /usr/local/tomcat

# Remove as aplicações padrão do Tomcat para otimizar espaço e segurança
RUN rm -rf webapps/*

# Copia o arquivo .war gerado na Etapa 1 para o diretório de deploy do Tomcat
# Renomeamos para ROOT.war para que a aplicação responda diretamente na raiz (/) do servidor
COPY --from=builder /app/target/*.war ./webapps/ROOT.war

# Expõe a porta padrão do servidor Tomcat
EXPOSE 8080

# O comando de inicialização padrão já vem configurado na imagem base do Tomcat (catalina.sh run)