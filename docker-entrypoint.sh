#!/usr/bin/env bash
set -e

if [ "$1" = 'ldap' ]; then
  echo "Copy basic configuration from distribution"
  cp -Rf /etc/ldap/slapd.d/* /ldap-conf.d/

  chown -R openldap:openldap /ldap-conf.d/*

  echo "Starting slapd for provisioning"
  /usr/sbin/slapd -F /ldap-conf.d -u openldap -g openldap -h 'ldapi:// ldap://' -d stats &
  dpid=$!

  sleep 10

  echo "Add base configuration to slapd"

  ldapmodify -Y EXTERNAL -H ldapi:/// <<-EOCONF
		dn: olcDatabase={1}mdb,cn=config
		replace: olcRootPW
		olcRootPW: $LDAP_ROOT_PW
		-
		replace: olcSuffix
		olcSuffix: $LDAP_BASE_DN
		-
		# add: olcDbDirectory
		# olcDbDirectory: /data
		# -
		replace: olcRootDN
		olcRootDN: cn=admin,$LDAP_BASE_DN

		dn: olcDatabase={0}config,cn=config
		replace: olcRootPW
		olcRootPW: $LDAP_ROOT_PW
		EOCONF

  echo "Running additional provisioning"
  for f in /docker-entrypoint-initldap.d/*; do
    case "$f" in
      *.sh)     echo "$0: running $f"; . "$f" ;;
      *.ldif)    echo "$0: adding LDIF $f"; ldapadd -x -D "cn=admin,$LDAP_BASE_DN" -w $LDAP_ROOT_PW -f $f || true; echo ;;
      # ldapadd -Y EXTERNAL -H ldapi:/// < $f
      # ldapadd -Y EXTERNAL -H ldapi:/// -f $f
    esac
    echo
  done
  echo "Kill slapd for provisioning"
  kill $dpid

  echo "Start productive slapd"
  exec /usr/sbin/slapd -F /ldap-conf.d -u openldap -g openldap -h 'ldapi:// ldap://' -d stats
fi

exec "$@"
