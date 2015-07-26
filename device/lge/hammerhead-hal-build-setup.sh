TOOLDIR="$(dirname $0)/../.."

source "$TOOLDIR/utility-functions.inc"

source ~/.hadk.env

#pushd device/lge
#    rm -f cm.dependencies
#    git checkout cm.dependencies
#popd
#sed -i -n '/kernel/{N;s/.*//;x;d;};x;p;${x;p;}' ./device/lge/cm.dependencies
#sed -i "/},$/d" ./device/lge/cm.dependencies
#sed -i "/^$/d"  ./device/lge/cm.dependencies

#curl https://raw.githubusercontent.com/mer-hybris/android/hybris2-11.0/default.xml >  /tmp/manifest.xml
#cp /tmp/manifest.xml .repo/manifests/default.xml
#rm -f /tmp/manifest.xml
#sed -i "/_lge_hammerhead/d" .repo/manifests/default.xml
