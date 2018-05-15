#! /bin/ksh

#
# Usage: dotest.sh testdir [-sml <sml-path>] [-diff]
#

CMD=${0##*/}\>

# determine the default path to SML/NJ
if [ -x /usr/local/smlnj/bin/sml ] ; then
  SML_PATH=/usr/local/smlnj/bin/sml
elif [ -x /usr/local/bin/sml ] ; then
  SML_PATH=/usr/local/bin/sml
else
  SML_PATH=sml
fi
SMLX=${SML:-"$SML_PATH"}

ECHO=print
DIFFS=

# default ARCH and OPSYS
ARCH=${ARCH:-x86}
OPSYS=${OPSYS:-darwin}

#
# use the arch-n-opsys script to determine the ARCH/OS if possible
#
if [[ (-f ./bin/arch-n-opsys.sh) && (-x ./bin/arch-n-opsys.sh) ]]
then
  ARCH_N_OPSYS=`./bin/arch-n-opsys.sh`
  if [[ "$?" = "0" ]]
  then
    eval $ARCH_N_OPSYS
  fi
fi
SUFFIX="$ARCH-$OPSYS"

function printUsage {
 $ECHO -u2 "dotest.sh [options] testdir "
 $ECHO -u2 "    -sml <sml-path>]     default=$SMLX"
 $ECHO -u2 "    -diff               default=off"
 $ECHO -u2 "    -help"
}

while [[ $# -ne 0 ]]
do
    arg=$1; shift
    case $arg in
      -sml)
	if [[ $# -eq 0 ]]
	then
	    $ECHO $CMD must name executable with -sml option
	    exit 1
	fi
	SMLX=$1; shift
	;;
      -diff)
	DIFFS="-diff";
	;;
      -help)
	printUsage
	exit 0
	;;
      *)
	TESTDIR=$arg
	;;
    esac
done

if [ x"$TESTDIR" = x ] ; then
    printUsage
    exit 1
fi

#
# Make sure output files do not exist
#
if [[ -a $TESTDIR/LOG.$SUFFIX ]]
then
    $ECHO $CMD $TESTDIR/LOG.$SUFFIX exists -- please run bin/clean.sh
    exit 1
fi

if [[ -a $TESTDIR/RESULTS.$SUFFIX ]]
then
    $ECHO $CMD $TESTDIR/RESULTS.$SUFFIX exists -- please run bin/clean.sh
    exit 1
fi

#
# Go for it
#
$ECHO $CMD Running testml.sh for $TESTDIR ...
./bin/testml.sh $TESTDIR -sml $SMLX 1>$TESTDIR/LOG.$SUFFIX
if [[ $? -eq 0 ]]
then
	$ECHO $CMD Running process.sh for $TESTDIR ...
	./bin/process.sh $TESTDIR $DIFFS 1>$TESTDIR/RESULTS.$SUFFIX 2>&1
fi
