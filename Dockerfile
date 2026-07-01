# Estágio 1: Build da aplicação com Maven
FROM docker.io/library/maven:3.9.6-eclipse-temurin-17 AS builder
WORKDIR /app

# Copia o pom.xml e baixa as dependências (otimização de cache)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copia o código fonte e realiza o empacotamento
COPY src ./src
RUN mvn clean package -DskipTests

# Estágio 2: Ambiente de execução com Tomcat 9 (Java 8)
FROM docker.io/library/tomcat:9.0-jre8-alpine
WORKDIR /usr/local/tomcat

# Limpa os aplicativos padrão do Tomcat
RUN rm -rf webapps/*

# Copia cirurgicamente o war gerado no estágio anterior eliminando o wildcard problemático
COPY --from=builder /app/target/todo-tomcat-k8s.war ./webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]