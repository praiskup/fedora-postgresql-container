FROM registry.fedoraproject.org/fedora:25

# PostgreSQL image for OpenShift.
# Volumes:
#  * /var/lib/psql/data   - Database cluster for PostgreSQL
# Environment:
#  * $POSTGRESQL_USER     - Database user name
#  * $POSTGRESQL_PASSWORD - User's password
#  * $POSTGRESQL_DATABASE - Name of the database to create
#  * $POSTGRESQL_ADMIN_PASSWORD (Optional) - Password for the 'postgres'
#                           PostgreSQL administrative account

ENV POSTGRESQL_VERSION=9.5 \
    HOME=/var/lib/pgsql \
    PGUSER=postgres

LABEL io.k8s.description="PostgreSQL is an advanced Object-Relational database management system" \
      io.k8s.display-name="PostgreSQL 9.5" \
      io.openshift.expose-services="5432:postgresql" \
      io.openshift.tags="database,postgresql,postgresql95" \
      com.redhat.component="postgresql" \
      maintainer="Pavel Raiskup <praiskup@redhat.com>" \
      name="$FCG/postgresql" \
      version="0" \
      release="1.$DISTTAG" \
      architecture="x86_64" \
      usage="Run without arguments to get usage info." \
      help="/help.1"

EXPOSE 5432

ADD root /

# This image must forever use UID 26 for postgres user so our volumes are
# safe in the future. This should *never* change, the last test is there
# to make sure of that.
RUN INSTALL_PKGS="rsync tar gettext bind-utils postgresql-server postgresql-contrib nss_wrapper " && \
    INSTALL_PKGS+="findutils python " && \
    dnf -y --setopt=tsflags=nodocs install $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    dnf clean all && \
    test "$(id postgres)" = "uid=26(postgres) gid=26(postgres) groups=26(postgres)" && \
    mkdir -p /var/lib/pgsql/data && \
    /usr/libexec/fix-permissions /var/lib/pgsql && \
    /usr/libexec/fix-permissions /var/run/postgresql

# Get prefix path and path to scripts rather than hard-code them in scripts
ENV CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/postgresql

VOLUME ["/var/lib/pgsql/data"]

USER 26

ENTRYPOINT ["container-entrypoint"]
CMD ["run-postgresql"]
