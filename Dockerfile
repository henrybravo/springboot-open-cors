FROM public.ecr.aws/bitnami/java:1.8 as build
WORKDIR application

COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src

RUN ./mvnw  install -DskipTests

RUN cp /application/target/*.jar app.jar
RUN java -Djarmode=layertools -jar app.jar extract

FROM public.ecr.aws/bitnami/java:1.8
WORKDIR application
COPY --from=build application/dependencies/ ./
COPY --from=build application/spring-boot-loader/ ./
COPY --from=build application/snapshot-dependencies/ ./
COPY --from=build application/application/ ./
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]