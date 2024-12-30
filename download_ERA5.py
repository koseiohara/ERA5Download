import datetime
import sys
import os
import cdsapi

from setting import HOUR_DELTA, DOWNLOAD_DIR, DATASET, TYPE, DX, DY, LEVELS


###---###

INPUT_FMT = '%Y/%m/%d/%H'
INI_STR = sys.argv[1]
FIN_STR = sys.argv[2]

INI_DT = datetime.datetime.strptime(INI_STR, INPUT_FMT)
FIN_DT = datetime.datetime.strptime(FIN_STR, INPUT_FMT)

PARAM = sys.argv[3]
FILE_FMT = '{}.%Y%m%d%H'.format(PARAM)

###---###
calendar_delta = FIN_DT - INI_DT
nt = calendar_delta.days * int(24/HOUR_DELTA) + int(calendar_delta.seconds/(3600*HOUR_DELTA)) + 1

#print(FILE_FMT)
#print(nt)

calendar = INI_DT

client = cdsapi.Client()
print('----------')
print('<Start Download>')
for t in range(nt):
    dir_subdivide = DOWNLOAD_DIR + '/' + calendar.strftime('%Y%m')

    filename      = calendar.strftime(FILE_FMT)
    absolute_path = dir_subdivide + '/' + filename

    if (not os.path.isdir(dir_subdivide)):
        print('Make Directory : {}'.format(dir_subdivide))
        os.mkdir(dir_subdivide)

    print('Data Download to {}'.format(absolute_path))

    request = {'product_type'   : TYPE                        ,
               'variable'       : [PARAM]                     , 
               'year'           : [calendar.strftime('%Y')]   ,
               'month'          : [calendar.strftime('%m')]   ,
               'day'            : [calendar.strftime('%d')]   ,
               'time'           : [calendar.strftime('%H:%M')],
               'pressure_level' : LEVELS                      ,
               'grid'           : [DX,DY]                     ,
               'data_format'    : 'grib'                      ,
              }
    
    client.retrieve(DATASET, request, absolute_path)

    calendar = calendar + datetime.timedelta(hours=HOUR_DELTA)

