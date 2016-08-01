#!/bin/bash
TOOLDIR="$(dirname `which $0`)"
source "$TOOLDIR/utility-functions.inc"

# Build droid-hal and other middleware
# To be executed under the Mer SDK


[ -z "$MERSDK" ] && ${TOOLDIR}/exec-mer.sh $0
[ -z "$MERSDK" ] && exit 0

source ~/.hadk.env
[[ -f $TOOLDIR/proxy ]] && source $TOOLDIR/proxy
[[ ! -z  $http_proxy ]] && proxy="http_proxy=$http_proxy"

cd $ANDROID_ROOT

  cp $TOOLDIR/pack-audioflingerglue.sh $ANDROID_ROOT/
  cp $TOOLDIR/audioflingerglue.spec $ANDROID_ROOT/external/audioflingerglue/rpm/
  sh  $TOOLDIR/af.sh 0.0.1.201607221924

  sed -i "/rm \-rf \$RPM_BUILD_ROOT$/a rm -f out/target/product/*/system/lib/libaudioflingerglue.so" rpm/dhd/droid-hal-device.inc
  sed -i "/rm \-rf \$RPM_BUILD_ROOT$/a rm -f out/target/product/*/system/bin/miniafservice" rpm/dhd/droid-hal-device.inc
