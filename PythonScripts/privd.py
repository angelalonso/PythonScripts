import os
import subprocess
import glob

def mount_all(cryfs_map):
    pass

def bash(command):

    build_cmd = subprocess.Popen([command], stdout=subprocess.PIPE, shell=True)
    #(out_getmounts, err_getmounts) = build_cmd.communicate()
    ## TODO: manage errors or send them
    #return out_getmounts
    return build_cmd.communicate()


def check_files(folder):
    error_files = []
    for dirpath, dirnames, files in os.walk(folder):
        for name in files:
            file_in = (os.path.join(dirpath, name))
            if not os.path.isfile(file_in):
                error_files.append(file_in)

    return error_files
    

def test_mounts(cryfs_map):
    not_mounted = []
    wrong_mounted = []

    # Get mounted volumes
    for encrypted_folder in cryfs_map:
        enc_folder = cryfs_map[encrypted_folder].replace('$HOME', os.environ['HOME'])

        if not os.path.ismount(enc_folder):
            not_mounted.append(enc_folder)
        else:
            error_files = check_files(enc_folder)

    return "DONE"

if __name__ == "__main__":
    # TODO: Check you are on unix-like
    # TODO: Test on Macos
    # encrypted folder: mounted folder
    CRYFS_MAP = {
            '$HOME/Dropbox/.enc_a': '$HOME/Private',
            '$HOME/Dropbox/.enc_b': '$HOME/Private.bck'
           }
    print(test_mounts(CRYFS_MAP))
