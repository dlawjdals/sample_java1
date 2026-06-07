# 1단계: 빌드
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn -B dependency:go-offline      # 의존성 미리 받아 캐시
COPY src ./src
RUN mvn -B package -DskipTests        # jar 생성

# 2단계: 실행 (가벼운 JRE 이미지)
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
