FROM tomcat:9.0.85-jdk11-temurin

ENV GN_FILE geonetwork.war
ENV DATA_DIR=$CATALINA_HOME/webapps/geonetwork/WEB-INF/data
ENV JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true -server -Xms512m -Xmx2024m -XX:NewSize=512m -XX:MaxNewSize=1024m -XX:+UseConcMarkSweepGC"

#Environment variables
ENV GN_VERSION 4.4.1
#ENV GN_DOWNLOAD_MD5 0d05c65aa4ac67fea90fa74f947822d6


RUN </dev/null openssl s_client -connect ideandalucia.es:443 -servername ideandalucia  | openssl x509 > /tmp/ideandalucia.crt

RUN cd $JAVA_HOME/lib/security && \ 
	keytool -keystore cacerts -storepass changeit -noprompt -trustcacerts -importcert -alias idea -file /tmp/ideandalucia.crt


WORKDIR $CATALINA_HOME/webapps

RUN apt-get -y update && \
    apt-get -y install --no-install-recommends \
        curl \
        unzip 
COPY $GN_FILE /tmp
#RUN curl -fkSL -o $GN_FILE \
#     https://sourceforge.net/projects/geonetwork/files/GeoNetwork_opensource/v${GN_VERSION}/geonetwork.war/download && \
#     echo "$GN_DOWNLOAD_MD5 *$GN_FILE" | md5sum -c && \
RUN  mkdir -p geonetwork && \
     unzip -e /tmp/$GN_FILE -d geonetwork && \
     rm /tmp/$GN_FILE

#Set geonetwork data dir
COPY ./docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["catalina.sh", "run"]
