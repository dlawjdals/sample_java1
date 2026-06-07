# ── 1단계: 빌드 (Gradle로 jar 생성) ──
FROM eclipse-temurin:17-jdk AS build
WORKDIR /app

# Gradle 래퍼와 설정 파일 먼저 복사 (의존성 캐시 활용)
COPY gradlew .
COPY gradle gradle
COPY build.gradle settings.gradle ./
RUN sed -i 's/\r$//' gradlew && chmod +x gradlew
RUN ./gradlew dependencies --no-daemon || true   # 의존성 미리 받기

# 소스 복사 후 jar 빌드
COPY src src
RUN ./gradlew bootJar --no-daemon -x test

# ── 2단계: 실행 (가벼운 JRE 이미지) ──
FROM eclipse-temurin:17-jre
WORKDIR /app

# 빌드 단계에서 만들어진 jar만 가져옴
COPY --from=build /app/build/libs/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
