CREATE USER 'rt'@'%' IDENTIFIED WITH mysql_native_password BY 'RT@pipe18@';
GRANT ALL PRIVILEGES ON *.* TO 'rt'@'%';

CREATE DATABASE rt_alert_db_gcn_test;