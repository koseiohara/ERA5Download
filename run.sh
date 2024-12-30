#!/bin/bash

INI=1982
FIN=1984
SCRIPT=download.py
PARAMS_LIST="geopotential temperature u_component_of_wind v_component_of_wind vertical_velocity"

if [ ! -d log ]
then
    mkdir log
fi

for PARAM in ${PARAMS_LIST}
do
    echo "python ${SCRIPT} ${INI}/01/01/00 ${FIN}/12/31/18 ${PARAM} &>> log/log.txt &"
    python ${SCRIPT} ${INI}/01/01/00 ${FIN}/12/31/18 ${PARAM} &>> log/log.txt &
done

