su -s /bin/sh -c "keystone-manage db_sync" keystone

groupadd keystone
useradd -m -g keystone keystone
mkdir -p /etc/keystone/jws-keys
mkdir -p /etc/keystone/jws-keys/public
mkdir -p /etc/keystone/jws-keys/private
chown -R keystone:keystone /etc/keystone/jws-keys/
keystone-manage token_setup --keystone-user keystone --keystone-group keystone
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
keystone-manage create_jws_keypair --keystone-user keystone --keystone-group keystone
mv private.pem /etc/keystone/jws-keys/private
mv public.pem /etc/keystone/jws-keys/public
apache2ctl -D FOREGROUND &
keystone-manage bootstrap --bootstrap-password $KEYSTONE_ADMIN_PASSWORD \
  --bootstrap-admin-url http://$CONTROLLER:35357/v3/ \
  --bootstrap-internal-url http://$CONTROLLER:5000/v3/ \
  --bootstrap-public-url http://$CONTROLLER:5000/v3/ \
  --bootstrap-region-id RegionOne

echo "ServerName $CONTROLLER" >> /etc/apache2/apache2.conf

cat > /openrc <<EOF
export OS_USERNAME=admin
export OS_PASSWORD=$KEYSTONE_ADMIN_PASSWORD
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://$CONTROLLER:5000/v3
export OS_IDENTITY_API_VERSION=3
EOF

if [ -f /usr/bin/post-keystone.sh ]; then
    echo "Running post-keystone.sh script"
    /usr/bin/post-keystone.sh
fi

tail -f /var/log/apache2/*