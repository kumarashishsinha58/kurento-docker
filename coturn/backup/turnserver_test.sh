#!/bin/bash
foo=bar
echo "$foo"

NAT=true
EXTERNAL_IP=172.31.0.78
PUBLIC_IP=3.7.53.92
REALM=turn.4linesinfotech.com
TURN_USERNAME=kurento
TURN_PASSWORD=kurento

if [ $NAT = "true" -a -z "$EXTERNAL_IP" ]; then

  # Try to get public IP
  PUBLIC_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4) || echo "No public ip found on http://169.254.169.254/latest/meta-data/public-ipv4"
  if [ -z "$PUBLIC_IP" ]; then
    PUBLIC_IP=$(curl http://icanhazip.com) || exit 1
  fi

  # Try to get private IP
  PRIVATE_IP=$(ifconfig | awk '/inet addr/{print substr($2,6)}' | grep -v 127.0.0.1) || exit 1
  export EXTERNAL_IP="$PUBLIC_IP/$PRIVATE_IP"
  echo "Starting turn server with external IP: $EXTERNAL_IP"
fi

echo $EXTERNAL_IP 
echo $PUBLIC_IP 
echo 'min-port=49152' > /home/ubuntu/docker/kurento-docker/coturn/turnserver.conf
echo 'max-port=65535' >> /home/ubuntu/docker/kurento-docker/coturn/turnserver.conf
echo 'fingerprint' >> /home/ubuntu/docker/kurento-docker/coturn/turnserver.conf
echo 'lt-cred-mech' >> /home/ubuntu/docker/kurento-docker/coturn/turnserver.conf
echo "realm=$REALM" >> /home/ubuntu/docker/kurento-docker/coturn/turnserver.conf
echo 'log-file stdout' >> /home/ubuntu/docker/kurento-docker/coturn/turnserver.conf
echo "user=$TURN_USERNAME:$TURN_PASSWORD" >> /home/ubuntu/docker/kurento-docker/coturn/turnserver.conf
echo "NAT=$NAT" >> /home/ubuntu/docker/kurento-docker/coturn/turnserver.conf
echo "external-ip=$EXTERNAL_IP" >> /home/ubuntu/docker/kurento-docker/coturn/turnserver.conf

exec /usr/bin/turnserver "$@"
