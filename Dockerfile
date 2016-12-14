# vim:set ft=dockerfile:

FROM debian:jessie

MAINTAINER Arne Schubert <atd.schubert@gmail.com>

RUN set -x \
  && apt-get update \
  && apt-get upgrade -y \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y slapd ldap-utils \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir /docker-entrypoint-initldap.d \
  && mkdir /ldap-conf.d \
  && chown -R openldap:openldap /ldap-conf.d || fail "Cannot change owner of supplied volumes."


COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod a+x /docker-entrypoint.sh

VOLUME /ldap-conf.d
ENV LDAP_BASE_DN "dc=example,dc=com"
ENV LDAP_ROOT_PW admin
EXPOSE 389

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["ldap"]
