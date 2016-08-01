fold=droidmedia-$1
rm -rf $fold
mkdir $fold

mkdir -p $fold/out/target/product/$DEVICE/system/lib
mkdir -p $fold/out/target/product/$DEVICE/system/bin
mkdir -p $fold/external/droidmedia

cp ./out/target/product/$DEVICE/symbols/system/lib/libdroidmedia.so $fold/out/target/product/$DEVICE/system/lib/
cp ./out/target/product/$DEVICE/symbols/system/bin/minimediaservice $fold/out/target/product/$DEVICE/system/bin/
cp ./out/target/product/$DEVICE/symbols/system/bin/minisfservice $fold/out/target/product/$DEVICE/system/bin/
cp ./external/droidmedia/*.h $fold/external/droidmedia/
cp ./external/droidmedia/hybris.c $fold/external/droidmedia/

tar -cjvf ${fold}.tgz $fold 



