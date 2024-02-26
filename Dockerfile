FROM tomcat:9.0.85-jdk11-temurin

# Java Certs IDE de Andalucia,Junta de Andalucia
RUN </dev/null openssl s_client -connect www.ideandalucia.es:443 -servername ideandalucia  | openssl x509 > /tmp/ideandalucia.crt
RUN </dev/null openssl s_client -connect www.juntadeandalucia.es:443 -servername juntadeandalucia  | openssl x509 > /tmp/juntadeandalucia.crt

RUN cd $JAVA_HOME/lib/security && \ 
	keytool -keystore cacerts -storepass changeit -noprompt -trustcacerts -importcert -alias ideandalucia -file /tmp/ideandalucia.crt

RUN cd $JAVA_HOME/lib/security && \ 
	keytool -keystore cacerts -storepass changeit -noprompt -trustcacerts -importcert -alias juntadeandalucia -file /tmp/juntadeandalucia.crt

# Geonetwork deploy
WORKDIR $CATALINA_HOME/webapps

RUN apt-get -y update && \
    apt-get -y install --no-install-recommends \
        curl \
        unzip 

COPY $GN_FILE /tmp

RUN  mkdir -p $GN_DIR && \
     unzip -e /tmp/$GN_FILE -d $GN_DIR && \
     rm /tmp/$GN_FILE

COPY custom/ $CATALINA_HOME/webapps/$GN_DIR/ 

# Comprobacion de entorno para copia de logo
RUN if [ "$entorno" = "integracion" ]; then \
    mv $CATALINA_HOME/webapps/$GN_DIR/catalog/views/default/images/logo_rediam_INT.png $CATALINA_HOME/webapps/$GN_DIR/catalog/views/default/images/logo_rediam.png && \
    rm $CATALINA_HOME/webapps/$GN_DIR/catalog/views/default/images/logo_rediam_PRU.png; \
  elif [ "$entorno" = "pruebas" ]; then \
      mv $CATALINA_HOME/webapps/$GN_DIR/catalog/views/default/images/logo_rediam_PRU.png $CATALINA_HOME/webapps/$GN_DIR/catalog/views/default/images/logo_rediam.png && \
      rm $CATALINA_HOME/webapps/$GN_DIR/catalog/views/default/images/logo_rediam_INT.png; \
  fi

# Tomcat EntryPoint
COPY ./docker-entrypoint.sh /entrypoint.sh
RUN ["chmod", "+x", "/entrypoint.sh"]
ENTRYPOINT ["/entrypoint.sh"]

CMD ["catalina.sh", "run"]
