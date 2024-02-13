FROM tomcat:9.0.85-jdk11-temurin

# Environment variables
ENV GN_FILE geonetwork.war
ENV DATA_DIR=$CATALINA_HOME/webapps/geonetwork/WEB-INF/data
ENV JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true -server -Xms512m -Xmx2024m -XX:NewSize=512m -XX:MaxNewSize=1024m -XX:+UseConcMarkSweepGC"
ENV GN_VERSION 4.4.1

# Argumentos
ARG entorno

# Java Certs IDE de Andalucia,Junta de Andalucia
RUN </dev/null openssl s_client -connect www.ideandalucia.es:443 -servername ideandalucia  | openssl x509 > /tmp/ideandalucia.crt
RUN </dev/null openssl s_client -connect www.juntadeandalucia.es:443 -servername juntadeandalucia  | openssl x509 > /tmp/juntadeandalucia.crt

RUN cd $JAVA_HOME/lib/security && \ 
	keytool -keystore cacerts -storepass changeit -noprompt -trustcacerts -importcert -alias ideandalucia -file /tmp/ideandalucia.crt

# Geonetwork deploy
WORKDIR $CATALINA_HOME/webapps

RUN apt-get -y update && \
    apt-get -y install --no-install-recommends \
        curl \
        unzip 

COPY $GN_FILE /tmp

RUN  mkdir -p geonetwork && \
     unzip -e /tmp/$GN_FILE -d geonetwork && \
     rm /tmp/$GN_FILE

COPY custom/ $CATALINA_HOME/webapps/geonetwork/ 

# Comprobacion de entorno para copia de logo
RUN if [ "$entorno" = "integracion" ]; then \
    mv $CATALINA_HOME/webapps/geonetwork/catalog/views/default/images/logo_rediam_INT.png $CATALINA_HOME/webapps/geonetwork/catalog/views/default/images/logo_rediam.png && \
    rm $CATALINA_HOME/webapps/geonetwork/catalog/views/default/images/logo_rediam_PRU.png; \
  elif [ "$entorno" = "pruebas" ]; then \
      mv $CATALINA_HOME/webapps/geonetwork/catalog/views/default/images/logo_rediam_PRU.png $CATALINA_HOME/webapps/geonetwork/catalog/views/default/images/logo_rediam.png && \
      rm $CATALINA_HOME/webapps/geonetwork/catalog/views/default/images/logo_rediam_INT.png; \
  fi

# Tomcat EntryPoint
COPY ./docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["catalina.sh", "run"]
