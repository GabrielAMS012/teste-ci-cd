# Estágio 1: Build da aplicação com Maven e JDK 21
FROM maven:3.9-eclipse-temurin-21 AS build

# Define o diretório de trabalho dentro do contêiner
WORKDIR /app

# Copia o pom.xml primeiro para aproveitar o cache de camadas do Docker
COPY pom.xml .

# Baixa as dependências (esta camada será cacheada se o pom.xml não mudar)
RUN mvn dependency:go-offline

# Copia o restante do código-fonte
COPY src ./src

# Compila o projeto e cria o arquivo .jar. Pula os testes, pois já rodaram no CI.
RUN mvn package -DskipTests


# Estágio 2: Criação da imagem final de execução
# Usa uma imagem base leve, contendo apenas o JRE necessário para rodar a aplicação
FROM eclipse-temurin:21-jre-jammy

# Define o diretório de trabalho
WORKDIR /app

# Copia o artefato .jar gerado no estágio de build
# O curinga (*) lida com nomes de arquivo que incluem a versão
COPY --from=build /app/target/*.jar app.jar

# Expõe a porta padrão do Spring Boot
EXPOSE 8080

# Comando para iniciar a aplicação quando o contêiner for executado
ENTRYPOINT ["java", "-jar", "app.jar"]