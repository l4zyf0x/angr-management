#!/bin/bash
set -ex

python -m venv .venv
if [[ "$OSTYPE" == "msys" ]]; then
    source .venv/Scripts/activate
else
    source .venv/bin/activate
fi

# Install dependencies

python -m pip install -U pip wheel setuptools pyinstaller==5.5 unicorn==2.0.1
if [[ "$OSTYPE" == "darwin"* ]]; then
    pip install pillow # icon conversion on macOS
fi

pip install git+https://github.com/eliben/pyelftools#egg=pyelftools
pip install git+https://github.com/angr/archinfo.git#egg=archinfo
pip install git+https://github.com/angr/pyvex.git#egg=pyvex
pip install git+https://github.com/angr/cle.git#egg=cle
pip install git+https://github.com/angr/claripy.git#egg=claripy
pip install git+https://github.com/angr/ailment.git#egg=ailment
pip install --no-build-isolation git+https://github.com/angr/angr.git#egg=angr
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    pip install keystone-engine
    pip install git+https://github.com/angr/archr.git#egg=archr
fi

# Install angr-mangement
pip install -e .

# Bundle!
if [[ "$OSTYPE" != "darwin"* ]]; then
    python packaging/pyinstaller/bundle.py --onefile
fi
python packaging/pyinstaller/bundle.py --onedir

mkdir upload

# Prepare onefiles
ONEFILE_DIR=packaging/pyinstaller/onefile
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    source /etc/os-release
    cp $ONEFILE_DIR/angr-management upload/angr-management-onefile-$ID-$VERSION_ID
elif [[ "$OSTYPE" == "msys" ]]; then
    cp $ONEFILE_DIR/angr-management.exe upload/angr-management-onefile-win64.exe
fi

# Prepare onedirs
ONEDIR_DIR=packaging/pyinstaller/onedir
if [[ "$OSTYPE" == "darwin"* ]]; then
    mkdir /tmp/angr-management-dmg
    cp -r $ONEDIR_DIR/*.app /tmp/angr-management-dmg
    hdiutil create upload/angr-management-macOS.dmg -volname "angr-management nightly" -srcfolder /tmp/angr-management-dmg
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
    source /etc/os-release
    tar -C $ONEDIR_DIR -czf upload/angr-management-$ID-$VERSION_ID.tar.gz angr-management
elif [[ "$OSTYPE" == "msys" ]]; then
    OUTDIR=$(pwd)/upload
    pushd $ONEDIR_DIR
    7z a $OUTDIR/angr-management-win64.zip \*
    popd
fi
