fold=droidmedia-0.0.0
rm -rf $fold
mkdir $fold

mkdir -p $fold/out/target/product/hammerhead/system/lib
mkdir -p $fold/out/target/product/hammerhead/system/bin
mkdir -p $fold/external/droidmedia

cp ./out/target/product/hammerhead/system/lib/libdroidmedia.so $fold/out/target/product/hammerhead/system/lib/
cp ./out/target/product/hammerhead/system/bin/minimediaservice $fold/out/target/product/hammerhead/system/bin/
cp ./out/target/product/hammerhead/system/bin/minisfservice $fold/out/target/product/hammerhead/system/bin/
cp ./external/droidmedia/*.h $fold/external/droidmedia/
cp ./external/droidmedia/hybris.c $fold/external/droidmedia/

tar -cjvf ${fold}.tgz $fold 



