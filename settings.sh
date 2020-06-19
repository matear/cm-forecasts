#!/bin/bash

#=======================================================================
DESCRIPTION='CAFE-60 forecasts'

ENSSIZE=2
FORECAST_CYCLE_LEN_IN_YEARS=1
this_date=" 2019 11 1"
JULBASE="1800 1 1"

#=======================================================================
# Important directories
echo ${HOSTNAME}
if [ "${HOSTNAME:0:1}" = "g" ] ; then
        machine='gadi.nci.org.au'
        data_mover="vxk563@gadi-dm.nci.org.au"
        MOM_SRC_DIR="/home/548/pas548/src/mom_cafe"
        OUTPUT_DIR="/scratch/v14/vxk563/CAFE/forecasts/f_ALCG_test/WIP/"
        INITENSDIR_BASE="/g/data/v14/vxk563/CAFE/data_assimilation/d60/save"
        BASE_DIR="/g/data/v14/vxk563/coupled_climate-parameter_estimation-KSOS/CM21_c5"
        NP_MASTER=48
        queue='pbs'
        MOM_COMMAND="mpirun -np 128"
        BGC_PARAM_DIR=${BASE_DIR}"/INIT/bgc_para/"
        MOM_BIN_DIR=${MOM_SRC_DIR}"/exec/"${machine}"/CM2M/"
        dn2date=/home/548/pas548/bin/dn2date
        date2dn=/home/548/pas548/bin/date2dn
elif [ "${HOSTNAME:0:1}" = "m" ] ||  [ "${HOSTNAME:0:1}" = "n" ] ; then
	machine='magnus.pawsey.org.au'
	data_mover="vkitsios@hpc-data.pawsey.org.au"
	MOM_SRC_DIR="/group/pawsey0315/vkitsios/2code/mom_cafe/"
	PROJECT_DIR="/group/pawsey0315/CAFE/forecasts/f5b/WIP"
	BASE_DIR="/group/pawsey0315/CAFE/CM21_c5"
	INITENSDIR_BASE="/group/pawsey0315/CAFE/data_assimilation/d60/save"
	OUTPUT_DIR=${PROJECT_DIR}
	NP_MASTER=24
	queue='slurm'
	MOM_COMMAND="srun -N6 -n 128"
	BGC_PARAM_DIR=${BASE_DIR}"/INIT/bgc_para"
	MOM_BIN_DIR=${MOM_SRC_DIR}"/exec/"${machine}"/CM2M/"
	dn2date=./src/dn2date/dn2date
	date2dn=./src/dn2date/date2dn
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
forecast_name=f_ALCG_test
contact_name="Decadal Activity 1 - Data Assimilation"
references="O'Kane, T.J., Sandery, P.A., Monselesan, D.P., Sakov, P., Chamberlain, M.A., Matear, R.J., Collier, M., Squire, D. and Stevens, L., 2019, 'Coupled data assimilation and ensemble initialisation with application to multi-year ENSO prediction', Journal of Climate."

#=======================================================================
# System settings
this_date_print=`$dn2date $JULDAY ${JULBASE}`
EXPNAME=${control_name}-${data_assimilation_name}-${perturbation_name}-${forecast_name}-${this_date_print}-2members_1year_test
WDIR=${OUTPUT_DIR}/${EXPNAME}
REF_DIR=${WDIR}"/ref"
HEADER_MASTER=${REF_DIR}"/header_master."${machine}
HEADER_MOM=${REF_DIR}"/header_mom."${machine}

BATCHSIZE=1
DT="1800"

#=======================================================================
# EOF
#=======================================================================
