FROM quay.io/keycloak/keycloak:19.0.2 as builder

ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true
ENV KC_FEATURES=web-authn,openshift-integration
ENV KC_DB=postgres
ENV KEYCLOAK_LOGLEVEL=debug
# Install custom providers
COPY policies/target/*jar /opt/keycloak/providers/
COPY themes /opt/keycloak/themes
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:19.0.2
COPY --from=builder /opt/keycloak/ /opt/keycloak/
WORKDIR /opt/keycloak
# for demonstration purposes only, please make sure to use proper certificates in production instead
ENV KC_DB_URL=jdbc:postgresql://postgresql.sso-dev.svc.cluster.local:5432/keycloak
ENV KC_DB_USERNAME=keycloak
ENV KC_DB_PASSWORD=sso1234
ENV KC_HOSTNAME=keycloak.apps.home.myocp.net
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]

