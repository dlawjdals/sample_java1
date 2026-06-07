# ── 1단계: 빌드 (gradle 이미지로 jar 생성) ──
FROM gradle:8.7-jdk17 AS build
WORKDIR /app

# 설정 파일 먼저 복사 (의존성 캐시 활용)
COPY build.gradle settings.gradle ./
RUN gradle dependencies --no-daemon || true   # 의존성 미리 받기

# 소스 복사 후 실행 jar 빌드 (gradlew 대신 gradle 사용)
COPY src ./src
RUN gradle bootJar --no-daemon -x test

# ── 2단계: 실행 (가벼운 JRE 이미지) ──
FROM eclipse-temurin:17-jre
WORKDIR /app

# 빌드 단계에서 만들어진 실행 jar만 복사
COPY --from=build /app/build/libs/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
