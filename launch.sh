#!/bin/bash

#####################################################################
# File: launch.sh
# Author: Vassili Kitsios, adopted from Paul Sandery, adapted from Pavel Sakov
# Created: 2020
# Purpose: launching script for CAFE60 forecasts
# Description: initially launches a run from a source directory; re-starts the run from the run directory
#####################################################################

. settings.sh

RUNSCRIPTNAME=run_${SYSTEMNAME}_forecasts.sh

set -eu
CWD=`pwd`
mkdir -p $WDIR
mkdir -p $SAVE_EXP_DIR

if [ ! -f "${WDIR}/JULDAY.txt" ] ; then
    echo $JULDAY > ${WDIR}/JULDAY.txt
fi

if [ ! -f "${WDIR}/CYCLE_ID.txt" ] ; then
    echo 0 > ${WDIR}/CYCLE_ID.txt
    git log | head -n1 > $WDIR/cm-forecast.version.txt
    cd $MOM_SRC_DIR ; git log | head -n1 > $WDIR/mom_cafe.version.txt ; cd $CWD
    $dn2date $JULDAY $JULBASE > $WDIR/experiment_start_date.txt
fi
CYCLE_ID=`cat $WDIR/CYCLE_ID.txt | head -1`

if (( $# == 0 )) ; then
    if [ ! -f "${WDIR}/CYCLE_END.txt" ] ; then
        echo 1 > ${WDIR}/CYCLE_END.txt
    fi
else
    echo $1 > ${WDIR}/CYCLE_END.txt
fi
CYCLE_END=`cat ${WDIR}/CYCLE_END.txt | head -1`

echo "  running ${EXPNAME}, cycle ${CYCLE_ID}"
cd $WDIR
WDIR_pwd=`pwd`
cd $CWD
if [ "$CWD" != "$WDIR_pwd" ] ; then
    cp -r $0 settings.sh src ref $WDIR
fi

cp src/add_meta_data.py src/add_meta_data.sh ${WDIR}
cp $HEADER_MASTER ${WDIR}/${RUNSCRIPTNAME}
cat src/${RUNSCRIPTNAME}.in | sed "s|INPUT_NPMASTER|${NP_MASTER}|" >> ${WDIR}/${RUNSCRIPTNAME}
cd $WDIR

if [ "${queue}" = "pbs" ] ; then
    qsub -N ${this_date_print}-$CYCLE_ID ./${RUNSCRIPTNAME}
elif [ "${queue}" = "slurm" ] ; then
    sbatch -J ${this_date_print}-$CYCLE_ID ./${RUNSCRIPTNAME}
else
    echo 'Unsupported queing system'
    exit
fi

