#! /usr/bin/env bash

abort() {
    echo $*
    exit 1
}

features=('debug' 'iplookup' 'proxy' 'libnotify')

VERSION=

[ ! -f '../configure' ] && cd .. && ./autogen.sh && cd build
[ ! -f 'Makefile' ] && ../configure

clear
echo "Preparing new release, please stand by..."
if make dist >/dev/null; then
    VERSION="$(../configure --version | head -n1 | awk '{ print $3 }')"
else
    abort Tarball generation fails.
fi
echo

for ((i=0; i<${#features[@]}; i++)); do
    echo "Attempting to build ${features[$i]} support..."
    tar xJf pcmanx-gtk2-${VERSION}.tar.xz
    pushd pcmanx-gtk2-${VERSION}
    if ./configure --enable-${features[$i]} > ../build-${features[$i]}.log && make >> ../build-${features[$i]}.log 2>&1; then
        echo -e "\033[44;37mPassed!\033[m"
        rm ../build-${features[$i]}.log
    else
        abort "Feature '${features[$i]}' build fails. See build-${features[$i]}.log"
    fi
    popd
    rm -rf pcmanx-gtk2-${VERSION}
    echo
done

echo "Tarball pcmanx-gtk2-${VERSION} is ready now!"
echo
