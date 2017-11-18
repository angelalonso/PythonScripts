import subprocess

def mount_all(cryfs_map):
    pass

def test_mounts(cryfs_folders):
    # Get mounted volumes
    cmd_getmounts = "df -h"
    getmounts = subprocess.Popen([cmd_getmounts], stdout=subprocess.PIPE, shell=True)
    (out_getmounts, err_getmounts) = getmounts.communicate()

    for entry in out_getmounts


    return out_getmounts

if __name__ == "__main__":
    CRYFS_MAP = ['$HOME/Dropbox/.enc_a' : '$HOME/Private',
                 '$HOME/Dropbox/.enc_b' : '$HOME/Private.bck']
    print test_mounts(CRYFS_FOLDERS)
