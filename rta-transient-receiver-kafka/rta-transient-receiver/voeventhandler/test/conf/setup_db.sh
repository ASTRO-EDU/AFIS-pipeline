#!/bin/bash 
set -e

pushd ./

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $script_dir
command="mysql -u root -p\"${MYSQL_ROOT_PASSWORD}\" "
eval $command < create_rt_and_db.sql
eval "$command rt_alert_db_gcn_test" < rt_alert_db_gcn_test_schema.sql
echo "Database Configured"
popd