fold=audioflingerglue-$1
rm -rf $fold
mkdir $fold

mkdir -p $fold/out/target/product/${DEVICE}/system/lib
mkdir -p $fold/out/target/product/${DEVICE}/system/bin
mkdir -p $fold/external/audioflingerglue/rpm

cp ./out/target/product/${DEVICE}/system/lib/libaudioflingerglue.so $fold/out/target/product/${DEVICE}/system/lib/
cp ./out/target/product/${DEVICE}/system/bin/miniafservice $fold/out/target/product/${DEVICE}/system/bin/

cp ./external/audioflingerglue/*.h $fold/external/audioflingerglue/
cp ./external/audioflingerglue/hybris.c $fold/external/audioflingerglue/

tar -cjvf ${fold}.tgz $fold
