#!/bin/bash
TOOLDIR="$(dirname `which $0`)"
source "$TOOLDIR/utility-functions.inc"

# Build droid-hal and other middleware
# To be executed under the Mer SDK


[ -z "$MERSDK" ] && ${TOOLDIR}/exec-mer.sh $0
[ -z "$MERSDK" ] && exit 0

source ~/.hadk.env

cd $ANDROID_ROOT

mchapter "7.1.1"

minfo "updating mer sdk"
sudo zypper ref -f ; sudo zypper -n dup

if repo_is_set "$EXTRA_REPO"; then
  minfo "Add remote extra repo"
  sb2 -t $VENDOR-$DEVICE-$ARCH -R -m sdk-install ssu ar extra-$DEVICE $EXTRA_REPO
fi
if repo_is_set "$MW_REPO"; then
  minfo "Add remote mw repo"
  sb2 -t $VENDOR-$DEVICE-$ARCH -R -m sdk-install ssu ar mw-$DEVICE-hal $MW_REPO
fi

if [[ ! -d rpm/dhd ]]; then 
    if [[ -d hybris/dhd2modular ]] ; then 
        pushd hybris/dhd2modular
        git pull 
        popd
    else
        pushd hybris
        git clone git@github.com:sledges/dhd2modular.git
        popd
    fi  
    hybris/dhd2modular/dhd2modular.sh migrate 2>&1 | tee $ANDROID_ROOT/dhd.migrate.log
fi
mkdir -p droid-local-repo/hammerhead
rpm/dhd/helpers/build_packages.sh 2>&1 | tee $ANDROID_ROOT/dhd.build.log
