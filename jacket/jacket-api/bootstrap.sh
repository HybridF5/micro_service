#!/bin/bash

# create database for jacket
export MYSQL_ROOT_PASSWORD=${MYSQL_ENV_MYSQL_ROOT_PASSWORD:-MYSQL_PASS}
export MYSQL_HOST=${MYSQL_HOST:-127.0.0.1}
export MYSQL_PORT=${MYSQL_PORT:-3306}
export JACKET_DB_USER=${JACKET_DB_USER:-jacket}
export JACKET_DB_PASS=${JACKET_DB_PASS:-MYSQL_PASS}
export JACKET_DB_NAME=${JACKET_DB_NAME:-jacket}
export JACKET_API_DB_NAME=${JACKET_API_DB_NAME:-jacket_api}

SQL_SCRIPT=/opt/jacket/jacket.sql
mysql -uroot -p$MYSQL_ROOT_PASSWORD -h $MYSQL_HOST <$SQL_SCRIPT

# To create the Identity service credentials
KEYSTONE_HOST=${KEYSTONE_HOST:-keystone}
KEYSTONE_DOMAIN=${KEYSTONE_DOMAIN:-default}
ENDPOINT_REGION=${ENDPOINT_REGION:-RegionOne}

GLANCE_HOST=${GLANCE_HOST:-glance}

JACKET_USER_NAME=${JACKET_USER_NAME:-jacket}
JACKET_PASSWORD=${JACKET_PASSWORD:-JACKET_PASS}
JACKET_HOST=${JACKET_HOST:-0.0.0.0}
INSTANCES_PATH=${INSTANCES_PATH:-/root/mnt/sdb/instances}

NOVA_USER_NAME=${NOVA_USER_NAME:-nova}
NOVA_PASSWORD=${NOVA_PASSWORD:-NOVA_PASS}
METADATA_SHARED_SECRET=${METADATA_SHARED_SECRET:-NOVA_PASS}

CINDER_USER_NAME=${CINDER_USER_NAME:-cinder}
CINDER_PASSWORD=${CINDER_PASSWORD:-CINDER_PASS}

NEUTRON_USER_NAME=${NEUTRON_USER_NAME:-neutron}
NEUTRON_PASSWORD=${NEUTRON_PASSWORD:-NEUTRON_PASS}
NEUTRON_HOST=${NEUTRON_HOST:-neutron}

RABBITMQ_HOST=${RABBITMQ_HOST:-rabbitmq}
RABBITMQ_USER=${RABBITMQ_USER:-openstack}
RABBITMQ_PASSWORD=${RABBITMQ_PASSWORD:-RABBIT_PASS}

export OS_USERNAME=${OS_USERNAME:-admin}
export OS_PASSWORD=${OS_PASSWORD:-ADMIN_PASS}
export OS_TENANT_NAME=${OS_TENANT_NAME:-admin}
export OS_AUTH_URL=${OS_AUTH_URL:-http://${KEYSTONE_HOST}:35357/v2.0}

# For nova
#keystone user-create --name $NOVA_USER_NAME --pass $NOVA_PASSWORD
#keystone user-role-add --user $NOVA_USER_NAME --tenant service --role admin
#keystone service-create --name nova --description "OpenStack compute service" nova
#keystone endpoint-create \
#        --service-id $(keystone service-list | awk '/ nova / {print $2}') \
#        --publicurl http://${JACKET_HOST}:8774/v2.1/%\(tenant_id\)s \
#        --internalurl http://${JACKET_HOST}:8774/v2.1/%\(tenant_id\)s \
#        --adminurl http://${JACKET_HOST}:8774/v2.1/%\(tenant_id\)s \
#        --region regionOne

# For cinder
#keystone user-create --name $CINDER_USER_NAME --pass $CINDER_PASSWORD
#keystone user-role-add --user $CINDER_USER_NAME --tenant service --role admin
#keystone service-create --name cinder --description "OpenStack Block Storage" volume
#keystone endpoint-create \
#        --service-id $(keystone service-list | awk '/ cinder / {print $2}') \
#        --publicurl http://${JACKET_HOST}:8776/v2/%\(tenant_id\)s \
#        --internalurl http://${JACKET_HOST}:8776/v2/%\(tenant_id\)s \
#        --adminurl http://${JACKET_HOST}:8776/v2/%\(tenant_id\)s \
#        --region regionOne

# For jacket
#keystone user-create --name $JACKET_USER_NAME --pass $JACKET_PASSWORD
#keystone user-role-add --user $JACKET_USER_NAME --tenant service --role admin
#keystone service-create --name jacket --description "OpenStack jacket service" jacket
#keystone endpoint-create \
#	--service-id $(keystone service-list | awk '/ jacket / {print $2}') \
#	--publicurl http://${JACKET_HOST}:9774/v1/%\(tenant_id\)s \
#	--internalurl http://${JACKET_HOST}:9774/v1/%\(tenant_id\)s \
#	--adminurl http://${JACKET_HOST}:9774/v1/%\(tenant_id\)s \
#	--region regionOne

# update jacket.conf
CONFIG_FILE=/etc/jacket/jacket.conf
crudini $CONFIG_FILE database connection "mysql+pymysql://${JACKET_DB_USER}:${JACKET_DB_PASS}@${MYSQL_HOST}:${MYSQL_PORT}/${JACKET_DB_NAME}"
crudini $CONFIG_FILE database retry_interval 10
crudini $CONFIG_FILE database idle_timeout 3600
crudini $CONFIG_FILE database min_pool_size 1
crudini $CONFIG_FILE database max_pool_size 10
crudini $CONFIG_FILE database max_retries 100
crudini $CONFIG_FILE database pool_timeout 10

# api database
crudini $CONFIG_FILE api_database connection "mysql+pymysql://${JACKET_DB_USER}:${JACKET_DB_PASS}@${MYSQL_HOST}:${MYSQL_PORT}/${JACKET_API_DB_NAME}"
crudini $CONFIG_FILE api_database retry_interval 10
crudini $CONFIG_FILE api_database idle_timeout 3600
crudini $CONFIG_FILE api_database min_pool_size 1
crudini $CONFIG_FILE api_database max_pool_size 10
crudini $CONFIG_FILE api_database max_retries 100
crudini $CONFIG_FILE api_database pool_timeout 10

crudini $CONFIG_FILE keystone_authtoken auth_uri http://$KEYSTONE_HOST:5000
crudini $CONFIG_FILE keystone_authtoken auth_url http://$KEYSTONE_HOST:35357
crudini $CONFIG_FILE keystone_authtoken auth_type password
crudini $CONFIG_FILE keystone_authtoken project_domain_name $KEYSTONE_DOMAIN
crudini $CONFIG_FILE keystone_authtoken user_domain_name $KEYSTONE_DOMAIN
crudini $CONFIG_FILE keystone_authtoken project_name $KEYSTONE_DOMAIN
crudini $CONFIG_FILE keystone_authtoken username $JACKET_USERNAME
crudini $CONFIG_FILE keystone_authtoken password $JACKET_PASSWORD
#crudini $CONFIG_FILE keystone_authtoken memcached_servers $KEYSTONE_HOST:11211

crudini $CONFIG_FILE DEFAULT osapi_jacket_listen "${JACKET_HOST}"
crudini $CONFIG_FILE DEFAULT osapi_compute_listen "${JACKET_HOST}"
crudini $CONFIG_FILE DEFAULT metadata_listen "${JACKET_HOST}"
crudini $CONFIG_FILE DEFAULT osapi_volume_listen "${JACKET_HOST}"
crudini $CONFIG_FILE DEFAULT debug "true"
crudini $CONFIG_FILE DEFAULT log_dir "/var/log/jacket"
crudini $CONFIG_FILE wsgi api_paste_config "/etc/jacket/jacket-api-paste.ini"
crudini $CONFIG_FILE DEFAULT image_service jacket.compute.image.glance.GlanceImageService

crudini $CONFIG_FILE DEFAULT rpc_backend rabbit
crudini $CONFIG_FILE oslo_messaging_rabbit rabbit_host $RABBITMQ_HOST
crudini $CONFIG_FILE oslo_messaging_rabbit rabbit_password $RABBITMQ_PASSWORD
crudini $CONFIG_FILE oslo_messaging_rabbit rabbit_userid $RABBITMQ_USER
crudini $CONFIG_FILE oslo_messaging_rabbit rabbit_port 5672
crudini $CONFIG_FILE oslo_messaging_rabbit rabbit_use_ssl false
#crudini $CONFIG_FILE oslo_messaging_rabbit rabbit_virtual_host /
crudini $CONFIG_FILE oslo_messaging_rabbit rabbit_max_retries 0
crudini $CONFIG_FILE oslo_messaging_rabbit rabbit_retry_interval 1
crudini $CONFIG_FILE oslo_messaging_rabbit rabbit_ha_queues false

#compute
crudini $CONFIG_FILE DEFAULT compute_driver libvirt.LibvirtDriver
crudini $CONFIG_FILE DEFAULT firewall_driver jacket.compute.virt.firewall.NoopFirewallDriver
crudini $CONFIG_FILE DEFAULT rootwrap_config /etc/jacket/rootwrap.conf
crudini $CONFIG_FILE DEFAULT compute_topic "jacket-worker"
crudini $CONFIG_FILE DEFAULT volume_topic "jacket-worker"
crudini $CONFIG_FILE DEFAULT use_local true
crudini $CONFIG_FILE DEFAULT instances_path ${INSTANCES_PATH}
#crudini $CONFIG_FILE libvirt virt_type qemu

# storage
backend="lvm"
crudini $CONFIG_FILE DEFAULT enabled_backends ${backend}
crudini $CONFIG_FILE ${backend} lvm_type "default"
crudini $CONFIG_FILE ${backend} iscsi_helper "tgtadm"
crudini $CONFIG_FILE ${backend} volume_driver jacket.storage.volume.drivers.lvm.LVMVolumeDriver
crudini $CONFIG_FILE ${backend} volume_group cinder-volumes
crudini $CONFIG_FILE ${backend} volumes_dir /var/lib/cinder/volumes
crudini $CONFIG_FILE ${backend} volume_backend_name lvm

#neutron
neutron="neutron"
crudini $CONFIG_FILE DEFAULT use_neutron "True"
crudini $CONFIG_FILE neutron url "http://$NEUTRON_HOST:9696"
crudini $CONFIG_FILE neutron neutron_default_tenant_id default
crudini $CONFIG_FILE neutron auth_type password
crudini $CONFIG_FILE neutron auth_section keystone_authtoken
crudini $CONFIG_FILE neutron auth_url "http://$KEYSTONE_HOST:35357"
crudini $CONFIG_FILE neutron project_domain_name $KEYSTONE_DOMAIN
crudini $CONFIG_FILE neutron user_domain_name $KEYSTONE_DOMAIN
crudini $CONFIG_FILE neutron region_name $ENDPOINT_REGION
crudini $CONFIG_FILE neutron project_name service
crudini $CONFIG_FILE neutron username $NEUTRON_USER_NAME
crudini $CONFIG_FILE neutron password $NEUTRON_PASSWORD
crudini $CONFIG_FILE neutron service_metadata_proxy True
crudini $CONFIG_FILE neutron metadata_proxy_shared_secret $METADATA_SHARED_SECRET
crudini $CONFIG_FILE DEFAULT linuxnet_ovs_integration_bridge br-int
crudini $CONFIG_FILE neutron ovs_bridge br-int

# sync the database
#jacket-manage db sync

mkdir -p /var/log/jacket

# create a admin-openrc.sh file
ADMIN_OPENRC=/root/admin-openrc.sh
cat >$ADMIN_OPENRC <<EOF
export OS_TENANT_NAME=$OS_TENANT_NAME
export OS_USERNAME=$OS_USERNAME
export OS_PASSWORD=$OS_PASSWORD
export OS_AUTH_URL=$OS_AUTH_URL
EOF

# start jacket-api service
#jacket-api &

