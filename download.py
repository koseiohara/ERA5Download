import datetime
import sys
import os
import cdsapi

from setting import HOUR_DELTA, DOWNLOAD_DIR, DATASET, TYPE, DX, DY, LEVELS


###--Get Setting--###
INPUT_FMT = '%Y/%m/%d/%H'
INI_STR = sys.argv[1]
FIN_STR = sys.argv[2]

INI_DT = datetime.datetime.strptime(INI_STR, INPUT_FMT)
FIN_DT = datetime.datetime.strptime(FIN_STR, INPUT_FMT)

PARAM = sys.argv[3]
FILE_FMT = '{}.%Y%m%d%H'.format(PARAM)

TRY_MAX = 5
###---------------###

calendar_delta = FIN_DT - INI_DT
nt = calendar_delta.days * int(24/HOUR_DELTA) + int(calendar_delta.seconds/(3600*HOUR_DELTA)) + 1

# Initialize calendar
calendar = INI_DT

LOG_NAME    = 'log/log_' + PARAM + '_' + INI_DT.strftime('%Y%m%d') + '_' + FIN_DT.strftime('%Y%m%d') + '.txt'
LOG_POINTER = open(LOG_NAME, mode='w')

LOG_POINTER.write('----------\n')
LOG_POINTER.write('<Start Download>\n')

try:
    # Access to ECMWF
    client = cdsapi.Client()
except:
    # Error to log file
    LOG_POINTER.write('---\n')
    LOG_POINTER.write('<ERROR STOP>\n')
    LOG_POINTER.write('Authentication failed\n')
    exit(1)

# Refrect written characters to log
LOG_POINTER.flush()

for t in range(nt):
    # Get directory
    dir_subdivide = DOWNLOAD_DIR + '/' + calendar.strftime('%Y%m')
    # Absolute path to the output file
    filename      = calendar.strftime(FILE_FMT)
    absolute_path = dir_subdivide + '/' + filename

    # If directory does not exist, execute mkdir
    if (not os.path.isdir(dir_subdivide)):
        LOG_POINTER.write('Make Directory : {}\n'.format(dir_subdivide))
        os.mkdir(dir_subdivide)

    # Dictionary format setting
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

    if (not os.path.isfile(absolute_path)):
        now = datetime.datetime.now()
        now_str = now.strftime('%Y/%m/%d %H:%M:%S')
        LOG_POINTER.write('{} -- Data Download to {}\n'.format(now_str, absolute_path))

        # Try downloading $TRY_MAX times 
        for i in range(TRY_MAX):
            try:
                # If successed, go to the next file
                client.retrieve(DATASET, request, absolute_path)
                break
            except:
                LOG_POINTER.write('Failed to download file : ')
                if (i < TRY_MAX-1):
                    LOG_POINTER.write('Try again\n')
                else:
                    LOG_POINTER.write('Go to the next file\n')
                    break

    else:
        # If file has already exist, skip downloading
        LOG_POINTER.write('{} already exist\n'.format(absolute_path))

    calendar = calendar + datetime.timedelta(hours=HOUR_DELTA)
    LOG_POINTER.flush()

LOG_POINTER.write('<End of Script>\n')
LOG_POINTER.flush()
LOG_POINTER.close()



