#!/bin/bash

INI="1982/01/01/00"
FIN="1982/12/31/18"
FIN="1982/01/02/18"
HOUR_DELTA=6
SCRIPT=download.py
PARAMS_LIST="geopotential temperature u_component_of_wind v_component_of_wind vertical_velocity"
DIVIDE=6

if [ ! -d log ]
then
    mkdir log
fi



INI_FMT_MODIFY="${INI:0:4}-${INI:5:2}-${INI:8:2} ${INI:11:2}:00"
FIN_FMT_MODIFY="${FIN:0:4}-${FIN:5:2}-${FIN:8:2} ${FIN:11:2}:00"
INI_TS=$(date --date "${INI_FMT_MODIFY}" "+%s")
FIN_TS=$(date --date "${FIN_FMT_MODIFY}" "+%s")

# Divide preriod to $DIVIDE parts
DAYS_TOT=$(((FIN_TS - INI_TS)/(24*3600)+1)) 
# If number of days is larger than $DIVIDE, modify $DIVIDE to smaller value
while [ "${DAYS_TOT}" -lt "${DIVIDE}" ]
do
    DIVIDE=$((DIVIDE-1))
done
DAYS_EACH=$((DAYS_TOT/DIVIDE))              # Number of days par each section
HOURS=$((DAYS_EACH*24-HOUR_DELTA))          # Number of hours per each section

echo
echo "========================="
echo "INITIAL : ${INI}"
echo "FINAL   : ${FIN}"
echo "DIVIDED INTO $DIVIDE PARTS"
echo "TOTAL DAYS : ${DAYS_TOT}"
echo "EACH DAYS  : ${DAYS_EACH}"
echo "========================="
echo

DIVIDE_INI_FMT=${INI_FMT_MODIFY}
DIVIDE_INI=$(date --date "${DIVIDE_INI_FMT}" "+%Y/%m/%d/%H")
for i in $(seq 1 1 ${DIVIDE})
do
    # Get the final datetime of the section
    if [ ${i} != ${DIVIDE} ]
    then
        DIVIDE_FIN_FMT=$(date --date "${DIVIDE_INI_FMT} ${HOURS} hours" "+%Y-%m-%d %H:00")
        DIVIDE_FIN=$(date --date "${DIVIDE_FIN_FMT}" "+%Y/%m/%d/%H")
    else
        DIVIDE_FIN=${FIN}
    fi

    for PARAM in ${PARAMS_LIST}
    do
        # Execute
        echo "python ${SCRIPT} ${DIVIDE_INI} ${DIVIDE_FIN} &>> log/log.txt &"
        #python ${SCRIPT} ${DIVIDE_INI} ${DIVIDE_FIN} &>> log/log.txt &
    done

    # Update the initial datetime for the next section
    DIVIDE_INI_FMT=$(date --date "${DIVIDE_FIN_FMT} ${HOUR_DELTA} hours" "+%Y-%m-%d %H:00")
    DIVIDE_INI=$(date --date "${DIVIDE_INI_FMT}" "+%Y/%m/%d/%H")
done

