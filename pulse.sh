#!/bin/bash

# Build droid-hal and other middleware
# To be executed under the Mer SDK
TOOLDIR="$(dirname `which $0`)"
source "$TOOLDIR/utility-functions.inc"


[ -z "$MERSDK" ] && $(dirname $0)/exec-mer.sh $0
[ -z "$MERSDK" ] && exit 0
set -x 
source ~/.hadk.env
[[ -f $TOOLDIR/proxy ]] && source $TOOLDIR/proxy
[[ ! -z  $http_proxy ]] && proxy="http_proxy=$http_proxy"

cd $ANDROID_ROOT
# THE COMMAND BELOW WILL FAIL. It's normal, carry on with the next one.
# Explanation: force installing of build-requirements by specifying the
# .inc file directly, but build-dependencies will be pulled in via
# zypper, so that the next step has all macro definitions loaded

createrepo $ANDROID_ROOT/droid-local-repo/$DEVICE
sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install zypper ref

   sb2 -t $VENDOR-$DEVICE-$ARCH -R -m sdk-install ssu rr local 
   sb2 -t $VENDOR-$DEVICE-$ARCH -R -m sdk-install zypper  ar local $ANDROID_ROOT/droid-local-repo/$DEVICE
   sb2 -t $VENDOR-$DEVICE-$ARCH -R -m sdk-install zypper  lr 
    sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install zypper in audioflingerglue-devel "pkgconfig(libdroid-util)" 
    PKG=pulseaudio-modules-droid-glue
    echo -e "\e[01;32m Info: build $PKG\e[00m"
    SPEC=$PKG
    mkdir -p $MER_ROOT/devel/mer-hybris
    
    cd $MER_ROOT/devel/mer-hybris
    if [ -d $PKG ] ; then
      echo -e "\e[01;32m Info: update the git $PKG\e[00m"
      cd $PKG
      git pull
    else
      echo -e "\e[01;32m Info: clone the git $PKG\e[00m"
      git clone https://github.com/mer-hybris/$PKG.git
  #       git clone https://github.com/foolab/$PKG.git 
      #git clone https://github.com/foolab/$PKG.git -b droidmedia
      #git clone https://github.com/foolab/$PKG.git -b caps
      cd $PKG
    fi

    echo -e "\e[01;32m Info: mb2 -s rpm/$PKG.spec -t $VENDOR-$DEVICE-armv7hl build &> $PKG.log \e[00m"
    mb2 -s rpm/$PKG.spec -t $VENDOR-$DEVICE-armv7hl build &> $ANDROID_ROOT/$PKG.log 
    tail -n 5 $ANDROID_ROOT/$PKG.log
    mkdir -p $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/
    rm -f $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/*.rpm
    mv RPMS/*.rpm $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG
    createrepo $ANDROID_ROOT/droid-local-repo/$DEVICE
