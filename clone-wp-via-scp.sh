while true; do
    read -p "¿seguro que quieres actualizar perdiendo los cambios?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

source config.sh

cd $devPath
#backup by git
#ssh -t root@178.62.66.154 "cd /var/www/html/urbansherpas ;mysqldump --opt -uroot -p4b$urdamentep0tente --add-drop-table --lock-tables --databases woocommerce > clone-wp-db-last.sql; cat clone-wp-db-last.sql ; rm backup.tar.gz; tar zcf "backup.tar.gz" -P ./*;"

ssh -p $prodServerPort -t $prodServerUser@$prodSeverUrl "cd $filesPath ;mysqldump --opt -u$DBUser -p$DBPwd --add-drop-table --lock-tables --databases $DBname > backup-db-last.sql; rm backup.tar.gz; tar zcf "backup.tar.gz" -P ./*;"
scp -P $prodServerPort -r $prodServerUser@$prodSeverUrl:$filesPath/backup.tar.gz $devPath

tar -xzvf backup.tar.gz
echo 'Autobackup from production done.'
echo 'Creating database...'
echo "type the mysql password for $devDBUser @ development server"

if [ "$DBUser" != "$devDBUser" ]; then
 mysql -u$devDBUser -p$devDBPwd -e "CREATE USER '$DBUser'@'localhost' IDENTIFIED BY PASSWORD('$DBPwd');"
 echo "DBUser != devDBUser";
fi;

if [ "$DBUser" == "$devDBUser" ]; then
 mysql -u$devDBUser -p$devDBPwd -e "SET PASSWORD FOR '$DBUser'@'localhost' = PASSWORD('$DBPwd');"
 echo "DBUser == devDBUser";
fi;

mysqladmin -u$DBUser -p$DBPwd -f drop $DBname
mysqladmin -u$DBUser -p$DBPwd create $DBname
mysql -u$DBUser -p$DBPwd $DBname < backup-db-last.sql
echo "db updated"


echo "define('DB_NAME', '$DBname');" >> wp-config.php
echo "define('DB_USER', '$devDBUser');" >> wp-config.php
echo "define('DB_PASSWORD', '$devDBPwd');" >> wp-config.php

echo "define('WP_HOME','$devServerUrl');" >> wp-config.php
echo "define('WP_SITEURL','$devServerUrl');" >> wp-config.php

echo "clone-wp/" >> .gitignore
echo "installBySCP.sh" >> .gitignore
echo "installFromGit.sh" >> .gitignore

git update-index --assume-unchanged wp-config.php .gitignore

#intended to work in codio.io
parts install php5 php5-apache2 php5-pdo-mysql php5-zlib mysql
parts stop apache2 mysql
parts start apache2 mysql
echo "parts stop apache2 mysql" >> $devPath/startup.sh ;
echo "parts start apache2 mysql" >> $devPath/startup.sh ;
