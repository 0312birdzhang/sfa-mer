TOOLDIR="$(dirname $0)/../.."

source "$TOOLDIR/utility-functions.inc"

source ~/.hadk.env
ls 

#pushd device/lge
#    rm -f cm.dependencies
#    git checkout cm.dependencies
#popd
#sed -i -n '/kernel/{N;s/.*//;x;d;};x;p;${x;p;}' ./device/lge/cm.dependencies
#sed -i "/},$/d" ./device/lge/cm.dependencies
#sed -i "/^$/d"  ./device/lge/cm.dependencies

sed -i "/_lge_hammerhead/d" .repo/manifests/default.xml
