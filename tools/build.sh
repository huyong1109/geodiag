DIRS=$GEODIAG_TOOLS/eemd

cd $GEODIAG_TOOLS/shared
for DIR in $DIRS; do
    res=$(make -f $DIR/Makefile)
    if [[ ! "$res" =~ "up to date" ]]; then
        echo "[Notice]: Geodiag: $(basename $DIR) has been built."
    fi
done
cd ~
