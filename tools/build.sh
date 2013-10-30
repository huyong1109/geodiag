DIRS=$GEODIAG_TOOLS/eemd

if [[ ! -d $GEODIAG_TOOLS/shared ]]; then
    mkdir $GEODIAG_TOOLS/shared
fi

cd $GEODIAG_TOOLS/shared
for DIR in $DIRS; do
    res=$(make -f $DIR/Makefile)
    if [[ ! "$res" =~ "up to date" ]]; then
        echo "[Notice]: Geodiag: $(basename $DIR) has been built."
    fi
done
cd ~
