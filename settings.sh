#!/bin/bash

#=======================================================================
DESCRIPTION='CAFE-60 forecasts'

ENSSIZE=96
FORECAST_CYCLE_LEN_IN_YEARS=10
#this_date=" 2010  2 1"
#this_date=" 2010  5 1"
#this_date=" 2010  8 1"
#this_date=" 2010 11 1" 
#this_date=" 2011  2 1"
#this_date=" 2011  5 1"
#this_date=" 2011  8 1"
#this_date=" 2011 11 1"
#this_date=" 2012  2 1"
#this_date=" 2012  5 1"
#this_date=" 2012  8 1"
#this_date=" 2012 11 1"
#this_date=" 2013  2 1"
#this_date=" 2013  5 1"
#this_date=" 2013  8 1"
#this_date=" 2013 11 1" 
#this_date=" 2014  2 1"
#this_date=" 2014  5 1"
#this_date=" 2014  8 1"
this_date=" 2014 11 1" 
#this_date=" 2015  2 1"
#this_date=" 2015  5 1"
#this_date=" 2015  8 1"
#this_date=" 2015 11 1"  # in progress
#this_date=" 2016  2 1"
#this_date=" 2016  5 1"
#this_date=" 2016  8 1"
#this_date=" 2016 11 1"  # complete
#this_date=" 2017  2 1"
#this_date=" 2017  5 1"
#this_date=" 2017  8 1"
#this_date=" 2017 11 1"  # complete
#this_date=" 2018  2 1"
#this_date=" 2018  5 1"
#this_date=" 2018  8 1"
#this_date=" 2018 11 1"  # complete
#this_date=" 2019  2 1"
#this_date=" 2019  5 1"
#this_date=" 2019  8 1"
#this_date=" 2019 11 1" 
#this_date=" 2020  2 1"
#this_date=" 2020  5 1"
#this_date=" 2020  8 1"
#this_date=" 2020 11 1" 
JULBASE="1800 1 1"

#=======================================================================
# Important directories
echo ${HOSTNAME}
if [ "${HOSTNAME:0:1}" = "g" ] ; then
        machine='gadi.nci.org.au'
        data_mover="vxk563@gadi-dm.nci.org.au"
        MOM_SRC_DIR="/home/548/pas548/src/mom_cafe"
        OUTPUT_DIR="/scratch/ux06/vxk563/CAFE/forecasts/f6/WIP/"
        SAVE_DIR="/g/data/v14/vxk563/CAFE/forecasts/f6/WIP/"
        INITENSDIR_BASE="/g/data/v14/vxk563/CAFE/data_assimilation/d60/save"
        BASE_DIR="/g/data/v14/vxk563/CAFE/CM21_c5"
        NP_MASTER=48
        queue='pbs'
        MOM_COMMAND="mpirun -np 128"
        BGC_PARAM_DIR=${BASE_DIR}"/INIT/bgc_para/"
        MOM_BIN_DIR=${MOM_SRC_DIR}"/exec/"${machine}"/CM2M/"
        dn2date=/home/548/pas548/bin/dn2date
        date2dn=/home/548/pas548/bin/date2dn
	PYTHON="/g/data/v14/ds0092/software/miniconda3/envs/zarrify/bin"
	POSTPROCESSING_SRCDIR="/g/data/v14/vxk563/CAFE/forecasts/post-processing"
	ZARR_PATH="/g/data/v14/ds0092/software/zarrtools"
elif [ "${HOSTNAME:0:1}" = "m" ] ||  [ "${HOSTNAME:0:1}" = "n" ] ; then
	machine='magnus.pawsey.org.au'
	data_mover="vkitsios@hpc-data.pawsey.org.au"
	MOM_SRC_DIR="/group/pawsey0315/vkitsios/2code/mom_cafe/"
	PROJECT_DIR="/group/pawsey0315/CAFE/forecasts/f5b/WIP"
	BASE_DIR="/group/pawsey0315/CAFE/CM21_c5"
	INITENSDIR_BASE="/group/pawsey0315/CAFE/data_assimilation/d60/save"
	OUTPUT_DIR=${PROJECT_DIR}
	SAVE_EXP_DIR=${PROJECT_DIR}
	NP_MASTER=24
	queue='slurm'
	MOM_COMMAND="srun -N6 -n 128"
	BGC_PARAM_DIR=${BASE_DIR}"/INIT/bgc_para"
	MOM_BIN_DIR=${MOM_SRC_DIR}"/exec/"${machine}"/CM2M/"
	dn2date=./src/dn2date/dn2date
	date2dn=./src/dn2date/date2dn
	PYTHON="??"
	POSTPROCESSING_SRCDIR="??"
	ZARR_PATH="??"
fi

echo "Running on machine "$machine
EXECNAME=fms_CM2M.x
SYSTEMNAME=CAFE

#=======================================================================
# Restart file locations on pearcey
JULDAY=`$date2dn $this_date $JULBASE`
if (( JULDAY > 73991 )) ; then
	RESTART_ARCHIVE_DIR="/OSM/CBR/OA_DCFP/data3/model_output/CAFE/data_assimilation/CAFE60/scratch/v14/tok599/cm-runs/CAFE-60/save/RESTART_"${JULDAY}
else
	RESTART_ARCHIVE_DIR="/OSM/CBR/OA_DCFP/data5/model_output/CAFE/data_assimilation/CAFE60/short/v14/tok599/cm-runs/CAFE-60/save/RESTART_"${JULDAY}
fi

INITENSDIR=$INITENSDIR_BASE"/RESTART_"${JULDAY}
if [ ! -d "${INITENSDIR}" ] ; then
	echo ""
	echo "Run following on pearcey-dm"
	echo "rsync -vhsrlt --chmod=Dg+s ${RESTART_ARCHIVE_DIR} ${data_mover}:${INITENSDIR_BASE}"
	echo ""
	exit
fi

#=======================================================================
# Metadata settings
control_name=c5
data_assimilation_name=d60
perturbation_name=pX
forecast_name=f6
contact_name="Decadal Activity 1 - Data Assimilation"
references="O'Kane, T.J., Sandery, P.A., Monselesan, D.P., Sakov, P., Chamberlain, M.A., Matear, R.J., Collier, M., Squire, D. and Stevens, L., 2019, 'Coupled data assimilation and ensemble initialisation with application to multi-year ENSO prediction', Journal of Climate."

#=======================================================================
# System settings
this_date_print=`$dn2date $JULDAY ${JULBASE}`
EXPNAME=${control_name}-${data_assimilation_name}-${perturbation_name}-${forecast_name}-${this_date_print}
WDIR=${OUTPUT_DIR}/${EXPNAME}
SAVE_EXP_DIR=${SAVE_DIR}/${EXPNAME}
REF_DIR=${WDIR}"/ref"
HEADER_MASTER=${REF_DIR}"/header_master."${machine}
HEADER_MOM=${REF_DIR}"/header_mom."${machine}

BATCHSIZE=1
DT="1800"

#=======================================================================
# EOF
#=======================================================================
