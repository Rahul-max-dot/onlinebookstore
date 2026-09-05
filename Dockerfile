
FROM tomcat:9.0-jdk21-temurin

RUN rm -rf /usr/local/tomcat/webapps/*

COPY target/onlinebookstore.war /usr/local/tomcat/webapps/onlinebookstore.war

EXPOSE 8080

CMD ["catalina.sh", "run"]

