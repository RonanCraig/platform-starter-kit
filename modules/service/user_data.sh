#!/bin/bash
TOKEN=$(curl -s -X PUT http://169.254.169.254/latest/api/token -H "X-aws-ec2-metadata-token-ttl-seconds: 60")
ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)
mkdir -p /srv/www
echo "<h1>Hello from $ID in $AZ</h1>" > /srv/www/index.html
systemd-run --unit web python3 -m http.server 80 --directory /srv/www
