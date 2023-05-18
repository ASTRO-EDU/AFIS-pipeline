# nohup watch -n 60 python ResultManager.py > watch.txt 
from config import get_config
import mysql.connector
import os
import pathlib
from os import listdir, makedirs
import re
from shutil import copy, move

conf_dict = get_config()

SFTP_DIR = "/data01/afiss-project/images"
DEST_DIR_ROOT = "/data01/AFISS-containers/local_dir/ANALYSIS3/AFISS"
REJECTED_DIR = "/data01/afiss-project/rejected"


def sequence_conversion(mission, seqnum):
    
    IDENTITY = seqnum
    MISSION = mission

    GW_ALERT_ID = 0

    if MISSION == 'LIGO_TEST' or MISSION == 'LIGO':

        THRESHOLD = 4.0

        if MISSION == 'LIGO_TEST':
            CHAR = 'MS'
        elif MISSION == 'LIGO':
            CHAR = 'S'

        if len(IDENTITY[6:]) == 2:
            GW_ALERT_ID = "%s%s%s" % (CHAR, IDENTITY[:6], chr(int(IDENTITY[6:8])+96))
            print("GW_ALERT_ID = ", GW_ALERT_ID)
        if len(IDENTITY[6:]) == 4:
            GW_ALERT_ID = "%s%s%s%s" % (CHAR, IDENTITY[:6], chr(int(IDENTITY[6:8])+96), chr(int(IDENTITY[8:10])+96))
            print ("GW_ALERT_ID = ", GW_ALERT_ID)
        if len(IDENTITY[6:]) == 6:
            GW_ALERT_ID = "%s%s%s%s%s" % (CHAR, IDENTITY[:6], chr(int(IDENTITY[6:8])+96), chr(int(IDENTITY[8:10])+96), chr(int(IDENTITY[10:12])+96))
            print ("GW_ALERT_ID = ", GW_ALERT_ID)
        if len(IDENTITY[6:]) == 8:
            GW_ALERT_ID = "%s%s%s%s%s" % (CHAR, IDENTITY[:6], chr(int(IDENTITY[6:8])+96), chr(int(IDENTITY[8:10])+96), chr(int(IDENTITY[10,12])+96), chr(int(IDENTITY[12,14])+96))
            print("GW_ALERT_ID = ", GW_ALERT_ID)
    else:
        GW_ALERT_ID = seqnum
    
    return GW_ALERT_ID



def mysql_connection():

    try:
        conn = mysql.connector.connect(host=conf_dict["db_host"], user=conf_dict["db_user"],\
        password=conf_dict["db_pass"], database=conf_dict["db_results"],port=int(conf_dict["db_port"]))
    
    except mysql.connector.Error as err:
        if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
            print("Something is wrong with your user name or password")
        elif err.errno == errorcode.ER_BAD_DB_ERROR:
            print("Database does not exist")
        else:
            print(err)

    cursor = conn.cursor()

    cursor.execute("select name,time,noticetime,triggerid,seqnum,noticeid,afisscheck from receivedsciencealert rsa \
    join instrument i on(i.instrumentid = rsa.instrumentid) join notice n \
    on (n.receivedsciencealertid = rsa.receivedsciencealertid) where \
    n.notice!='injected.' and afisscheck = 0 and noticetime > '2019-06-01' and n.seqnum in (select max(seqnum) \
    from notice join receivedsciencealert rsalert on \
    (rsalert.receivedsciencealertid = notice.receivedsciencealertid ) \
    where triggerid = rsa.triggerid) order by noticetime desc")

    results = cursor.fetchall()





    for value in results:
        print(value)


        
        sequence_number = sequence_conversion(value[0], str(value[3]))

        path_dir = os.path.join(DEST_DIR_ROOT, f"{value[0]}/{sequence_number}-{value[4]}")
        pathlib.Path(path_dir).mkdir(parents=True, exist_ok=True)

        #cursor.execute("update notice set afisscheck = 1 where noticeid=%s" % str(value[5]))
        #conn.commit()

    cursor.close()
    conn.close()
    

def check_results():
    """
    Filename has this structure:
    instrumentresults_resultname_alertinstrument_triggerid_seqnum.png
    filename examples:
    AGILE-MCAL_LC_LIGO_Ms20220808_2.png
    FERMI-GBM_MAP_SWIFT_1116221_0.png
    """
    
    files = listdir(SFTP_DIR)

    for f in files:

        path_splitted = re.split(r"[-.]", f)
        print(f)

        if (len(path_splitted)) != 6:
            print(f"Invalid format file {f} moving in /data01/afiss-project/rejected")
            move(os.path.join(SFTP_DIR, f), os.path.join(REJECTED_DIR,f))
        
        else:
            path_dir = os.path.join(DEST_DIR_ROOT, f"{path_splitted[2]}/{path_splitted[3]}-{path_splitted[4]}")
        
            if os.path.isdir(path_dir):
            
                subdir = os.path.join(path_dir, path_splitted[0])

                pathlib.Path(subdir).mkdir(parents=True, exist_ok=True)

                move(os.path.join(SFTP_DIR, f), os.path.join(subdir,f))
        
            else:
                print("directory " + path_dir + " not found, creating new directory..")
                subdir = os.path.join(path_dir, path_splitted[0])
                pathlib.Path(subdir).mkdir(parents=True, exist_ok=True)
                move(os.path.join(SFTP_DIR, f), os.path.join(subdir,f))
        

if __name__ == "__main__":
    
    mysql_connection()
    check_results()

