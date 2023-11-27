FROM registry.redhat.io/rhbk/keycloak-rhel9:22 as builder

ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true
ENV KC_FEATURES=web-authn,openshift-integration,scripts
ENV KC_DB=postgres
ENV KEYCLOAK_LOGLEVEL=warn
# Install custom providers
COPY policies/target/*jar /opt/keycloak/providers/
COPY themes /opt/keycloak/themes
WORKDIR /opt/keycloak
RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" -keystore conf/server.keystore
RUN /opt/keycloak/bin/kc.sh build

FROM registry.redhat.io/rhbk/keycloak-rhel9:22
COPY --from=builder /opt/keycloak/ /opt/keycloak/
WORKDIR /opt/keycloak
# for demonstration purposes only, please make sure to use proper certificates in production instead
ENV KC_DB_URL=jdbc:postgresql://postgresql:5432/keycloak
ENV KC_DB_USERNAME=keycloak
ENV KC_DB_PASSWORD=sso1234
ENV KC_HOSTNAME=keycloak.apps.home.myocp.net
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]

