#!/bin/bash
RDS_ENDPOINT=$(aws ssm get-parameter --name "rds_endpoint" --with-decryption --region ap-northeast-1  --output text --query Parameter.Value)
RDS_ROOT_USER=$(aws ssm get-parameter --name "root_db_user" --with-decryption --region ap-northeast-1  --output text --query Parameter.Value)
RDS_ROOT_PASS=$(aws ssm get-parameter --name "root_db_pass" --with-decryption --region ap-northeast-1  --output text --query Parameter.Value)
MYSQL_USER=$(aws ssm get-parameter --name "mysql_user" --with-decryption --region ap-northeast-1  --output text --query Parameter.Value)
MYSQL_PASS=$(aws ssm get-parameter --name "mysql-pass" --with-decryption --region ap-northeast-1  --output text --query Parameter.Value)

yum install -y httpd
systemctl start httpd.service
systemctl enable httpd.service

yum install -y mysql 
export MYSQL_HOST=$RDS_ENDPOINT
mysql --user=$RDS_ROOT_USER --password=$RDS_ROOT_PASS wordpress <<EOF
CREATE USER '$MYSQL_USER' IDENTIFIED BY '$MYSQL_PASS';
GRANT ALL PRIVILEGES ON wordpress.* TO wordpress;
FLUSH PRIVILEGES;
Exit
EOF

sudo -u ec2-user -i wget https://ja.wordpress.org/latest-ja.tar.gz
sudo -u ec2-user -i tar -xzf latest-ja.tar.gz

amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2

cp -r /home/ec2-user/wordpress/* /var/www/html/
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

sed -i s/database_name_here/wordpress/g /var/www/html/wp-config.php
sed -i s/username_here/$MYSQL_USER/g /var/www/html/wp-config.php
sed -i s/password_here/$MYSQL_PASS/g /var/www/html/wp-config.php
sed -i s/localhost/$RDS_ENDPOINT/g /var/www/html/wp-config.php
systemctl restart httpd.service
