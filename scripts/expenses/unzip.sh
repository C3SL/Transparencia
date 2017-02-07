echo Running with args $1 and $2

path="../../Favorecidos/"

mkdir ${path}$1
mv ~/Downloads/$2_GastosDiretos.zip ${path}$1
unzip ${path}$1/$2_GastosDiretos.zip
mv ${path}$2_GastosDiretos.csv ${path}$1
rm ${path}$1/$2_GastosDiretos.zip
