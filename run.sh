#!/bin/bash

INI="1982/01/01/00"
FIN="1982/12/31/18"
FIN="1982/01/01/18"
HOUR_DELTA=6
SCRIPT=download.py
PARAMS_LIST="geopotential temperature u_component_of_wind v_component_of_wind vertical_velocity"
DIVIDE=3

if [ ! -d log ]
then
    mkdir log
fi

function DAYNUM(){
    YEAR_INPUT=$1
    if [ $(expr ${YEAR_INPUT} % 4) != 0 ]
    then
                #     1  2  3  4  5  6  7  8  9 10 11 12
        DAYS_LIST=(0 31 28 31 30 31 30 31 31 30 31 30 31)
    elif [ $(expr ${YEAR_INPUT} % 100) = 0 -a $(expr ${YEAR_INPUT} % 400) != 0 ]
    then
                #     1  2  3  4  5  6  7  8  9 10 11 12
        DAYS_LIST=(0 31 28 31 30 31 30 31 31 30 31 30 31)
    else
                #     1  2  3  4  5  6  7  8  9 10 11 12
        DAYS_LIST=(0 31 29 31 30 31 30 31 31 30 31 30 31)
    fi
}


INI_FMT_MODIFY="${INI:0:4}-${INI:5:2}-${INI:8:2} ${INI:11:2}:00"
FIN_FMT_MODIFY="${FIN:0:4}-${FIN:5:2}-${FIN:8:2} ${FIN:11:2}:00"
INI_TS=$(date --date "${INI_FMT_MODIFY}" "+%s")
FIN_TS=$(date --date "${FIN_FMT_MODIFY}" "+%s")
DAYS_TOT=$(((FIN_TS - INI_TS)/(24*3600)+1)) 
DAYS_EACH=$((DAYS_TOT/DIVIDE))
HOURS=$((DAYS_EACH*24-HOUR_DELTA))
echo $DAYS_TOT
echo $DAYS_EACH
echo $HOURS
DIVIDE_INI_FMT=${INI_FMT_MODIFY}
DIVIDE_INI=$(date --date "${DIVIDE_INI_FMT}" "+%Y/%m/%d/%H")
for i in $(seq 1 1 ${DIVIDE})
do
    if [ ${i} != ${DIVIDE} ]
    then
        DIVIDE_FIN_FMT=$(date --date "${DIVIDE_INI_FMT} ${HOURS} hours" "+%Y-%m-%d %H:00")
        DIVIDE_FIN=$(date --date "${DIVIDE_FIN_FMT}" "+%Y/%m/%d/%H")
    else
        DIVIDE_FIN=${FIN}
    fi

    echo ${i}
    echo "python ${SCRIPT} ${DIVIDE_INI} ${DIVIDE_FIN} &>> log/log.txt &"
    #for PARAM in ${PARAMS_LIST}
    #do
    #    echo "python ${SCRIPT} ${INI}/01/01/00 ${FIN}/12/31/18 ${PARAM} &>> log/log.txt &"
    #    #python ${SCRIPT} ${INI}/01/01/00 ${FIN}/12/31/18 ${PARAM} &>> log/log.txt &
    #done

    DIVIDE_INI_FMT=$(date --date "${DIVIDE_FIN_FMT} ${HOUR_DELTA} hours" "+%Y-%m-%d %H:00")
    DIVIDE_INI=$(date --date "${DIVIDE_INI_FMT}" "+%Y/%m/%d/%H")
done

