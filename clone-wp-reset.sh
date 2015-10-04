while true; do
    read -p "¿seguro que quieres resetear perdiendo todos los cambios?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

source config.sh

cd $devPath
mv clone-wp* ../
rm -rf *
mv ../clone-wp* .
