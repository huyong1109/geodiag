DIRS=$GEODIAG_TOOLS/eemd

if [[ ! -d $GEODIAG_TOOLS/shared ]]; then
    mkdir $GEODIAG_TOOLS/shared
fi

cd $GEODIAG_TOOLS/shared
for DIR in $DIRS; do
    res=$(make -f $DIR/Makefile 2>&1)
    if [[ $? == 0 ]]; then
    	if [[ "$res" =~ "up to date" ]]; then
            notice "$(basename $DIR) is ready."
        else
        	notice "$(basename $DIR) has been built."
    	fi
	else
    	report_error_noexit "Sorry, EEMD is not compiled successfully! Report this bug to dongli@lasg.iap.ac.cn."
    fi
done
cd - > /dev/null
