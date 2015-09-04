#!/bin/bash
TOOLDIR="$(dirname `which $0`)"
source "$TOOLDIR/utility-functions.inc"

# Set up the crosscompiling environment Scratchbox2 and test it with a tiny program.
# To be executed under the Mer SDK


[ -z "$MERSDK" ] && ${TOOLDIR}/exec-mer.sh $0
[ -z "$MERSDK" ] && exit 0

source ~/.hadk.env
[[ -f $TOOLDIR/proxy ]] && source $TOOLDIR/proxy
[[ ! -z  $http_proxy ]] && proxy="http_proxy=$http_proxy"
minfo "sb2 setup"
if [[ ! -f $MER_ROOT/tmp/test ]]; then 
cd "$MER_ROOT"

    minfo "Work around curl"
    sudo $proxy zypper rr   curlfix || die
    sudo $proxy zypper ar -G http://repo.merproject.org/obs/home:/sledge:/mer/latest_i486/  curlfix || die
    sudo $proxy zypper  dup --from=curlfix|| die

SFFE_SB2_TARGET="$MER_ROOT/targets/$VENDOR-$DEVICE-$ARCH"
rm -rf $SFFE_SB2_TARGET
if [ -d "$SFFE_SB2_TARGET" ]; then
   minfo "SB2_TARGET $SFFE_SB2_TARGET exists, skipping creation"
   exit 0
fi
echo "TARGER=$TARGET"
TARGETS_URL=http://releases.sailfishos.org/sdk/latest/targets/targets.json
if [ -z "$TARGET" ]; then
    minfo "No target specified, assuming latest."
    TARBALL_URL=$(curl $TARGETS_URL | grep "${ARCH}.tar.bz2" | cut -d\" -f4 | sort | tail -n1)
else
    TARBALL_URL=$(curl $TARGETS_URL | grep "${ARCH}.tar.bz2" | grep $TARGET | cut -d\" -f4)
fi
TARBALL=$(basename $TARBALL_URL)

mkdir -p $SFFE_SB2_TARGET
#TARBALL=Jolla-1.1.7.24-Sailfish_SDK_Target-armv7hl.tar.bz2
if [ -f $TARBALL ] ; then
   minfo "using existing tarball $TARBALL ..."
else
   minfo "getting tarball $TARBALL ..."
   curl -O $TARBALL_URL || die
#    cp ~/Downloads/Jolla-1.1.7.24-Sailfish_SDK_Target-armv7hl.tar.bz2 .
fi

minfo "untaring ..."
sudo tar --numeric-owner -pxjf $TARBALL -C $SFFE_SB2_TARGET || die
mv ~/.scratchbox2{,-$(date +%d-%m-%Y.%H-%M-%S)}

minfo "chown $SFFE_SB2_TARGET to user"
[ $(stat -c %u $SFFE_SB2_TARGET ) == $(id -u) ] || sudo chown -R $USER $SFFE_SB2_TARGET

cd $SFFE_SB2_TARGET
grep :$(id -u): etc/passwd || grep :$(id -u): /etc/passwd >> etc/passwd
grep :$(id -g): etc/group  || grep :$(id -g): /etc/group  >> etc/group
if [ ! x"$(sb2-config -l)" = x"$VENDOR-$DEVICE-$ARCH" ] ; then
    minfo "calling sb2-init... " 
    sb2-init -d -L "--sysroot=/" -C "--sysroot=/" \
	-c /usr/bin/qemu-arm-dynamic -m sdk-build \
	-n -N -t / $VENDOR-$DEVICE-$ARCH \
	/opt/cross/bin/${ARCH}-meego-linux-gnueabi-gcc || die
    sb2 -t $VENDOR-$DEVICE-$ARCH -m sdk-install -R rpm --rebuilddb || die
    sb2 -t $VENDOR-$DEVICE-$ARCH -m sdk-install -R zypper ar \
        -G http://repo.merproject.org/releases/mer-tools/rolling/builds/$ARCH/packages/ mer-tools-rolling || die
    sb2 -t $VENDOR-$DEVICE-$ARCH -m sdk-install -R zypper  ref --force|| die
    sb2 -t $VENDOR-$DEVICE-$ARCH -m sdk-install -R zypper  dup || die
fi

mkdir -p "$MER_ROOT/tmp"
cd "$MER_ROOT/tmp"

minfo "testing newly installed tools"
cat > main.c << EOF
#include <stdlib.h>
#include <stdio.h>
int main(void) {
  printf("URAAAA!\n");
  return EXIT_SUCCESS;
}
EOF

sb2 -t $VENDOR-$DEVICE-$ARCH gcc main.c -o test || die "can't compile"
sb2 -t $VENDOR-$DEVICE-$ARCH ./test || die "can't run"
else
    sb2 -t $VENDOR-$DEVICE-$ARCH -m sdk-install -R zypper  ref --force|| die
    sb2 -t $VENDOR-$DEVICE-$ARCH -m sdk-install -R zypper  dup|| die
fi 
minfo "done sb2 setup"
