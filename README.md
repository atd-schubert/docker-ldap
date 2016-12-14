# LDAP Docker image

## Environment variables

* `LDAP_BASE_DN` (Default: "dc=example,dc=com") BaseDN of your LDAP-Server
* `LDAP_ROOT_PW` (Default: "admin") Password for Directory Admin "cn=admin,$LDAP_BASE_DN"

## Volumes

* `/ldap-conf.d` LDAP configuration folder (normally: /etc/ldap/slapd.d/)

## Exposed Ports

* `389` Default LDAP Ports

## Extend image

There is an initialization folder located at: `/docker-entrypoint-initldap.d`.

### Possible file-formats

* `*.sh` Runs a script as provisioning
* `*.ldif` Load LDIF into LDAP configuration
