import argparse
import glob
import logging as log
import os
import subprocess
import sys

# TODO:
#  - Sync .ssh, .aws, .kube?

# The folder where you store your keys for this password. TODO: remove .sysangel
FOLDRKEYS = os.environ['HOME'] + "/.privd"
# The mapping of encrypted folders and mountpoints
#            encrypted folder: mounted folder
CRYFS_MAP = {
            '$HOME/Dropbox/.enc_a': os.environ['HOME'] + '/Private',
            '$HOME/Dropbox/.enc_b': os.environ['HOME'] + '/.privd/Private.bck'
}


def mount_all(cryfs_map):
    log.debug("mounting all volumes")
    not_mounted = []
    # Get your password
    (pass_encfs, pass_err) = bash('/usr/bin/openssl rsautl -inkey ' + FOLDRKEYS + '/priv.key -decrypt < ' + FOLDRKEYS + '/cryfs.pass')

    for encrypted_folder in cryfs_map:
        dec_folder = cryfs_map[encrypted_folder].replace('$HOME', os.environ['HOME'])

        if not os.path.ismount(dec_folder):
            not_mounted.append(dec_folder)
            enc_folder = encrypted_folder.replace('$HOME', os.environ['HOME'])
            (mount_cryfs, mount_err) = bash('echo "' + pass_encfs + '" | cryfs ' + enc_folder + ' ' + dec_folder)
    return not_mounted


def unmount_all(cryfs_map):
    log.debug("unmounting all volumes")
    mounted = []

    for encrypted_folder in cryfs_map:
        dec_folder = cryfs_map[encrypted_folder].replace('$HOME', os.environ['HOME'])

        if os.path.ismount(dec_folder):
            mounted.append(dec_folder)
            (unmount_cryfs, unmount_err) = bash('fusermount -u "' + dec_folder + '"')

    # TODO:manage error sending
    return mounted


def bash(command):
    log.debug("running " + command)

    build_cmd = subprocess.Popen([command], stdout=subprocess.PIPE, shell=True)
    #(out_getmounts, err_getmounts) = build_cmd.communicate()
    ## TODO: manage errors or send them
    #return out_getmounts
    return build_cmd.communicate()


def check_files(folder):
    log.debug("checking files under folder " + folder)
    error_files = []
    for dirpath, dirnames, files in os.walk(folder):
        for name in files:
            file_in = (os.path.join(dirpath, name))
            if not os.path.isfile(file_in):
                error_files.append(file_in)

    return error_files
    

def test_mounts(cryfs_map):
    log.debug("testing mounts")
    wrong_files = {}

    # Get mounted volumes
    for encrypted_folder in cryfs_map:
        dec_folder = cryfs_map[encrypted_folder].replace('$HOME', os.environ['HOME'])
        if os.path.ismount(dec_folder):
            error_files = check_files(dec_folder)
            wrong_files[dec_folder] = error_files

    return wrong_files

if __name__ == "__main__":
    # TODO: Check you are on unix-like
    # TODO: Test on Macos
    parser = argparse.ArgumentParser()
    # Verbosity
    parser.add_argument('-m', '--mount', help='Mount all defined volumes', required=False, action='store_true')
    parser.add_argument('-u', '--umount', help='Unmount all defined volumes', required=False, action='store_true')
    parser.add_argument('-c', '--check', help='Check integrity of all defined volumes', required=False, action='store_true')
    parser.add_argument('-v', '--verbose', help='Show higher level of verbosity', required=False, action='store_true')

    args = vars(parser.parse_args())

    if args['verbose']:
        log.basicConfig(format="%(levelname)s: %(message)s", level=log.DEBUG)
    else:
        log.basicConfig(format="%(levelname)s: %(message)s", level=log.ERROR)

    if args['umount']:
        if args['mount']:
           log.error(' You have defined mounting and unmounting! \n If you want to do both, please, do one step at a time') 
           sys.exit(2)
        mounted = unmount_all(CRYFS_MAP)
        log.debug(mounted)
    elif args['mount']:
        not_mounted = mount_all(CRYFS_MAP)
        log.debug(not_mounted)
    elif args['check']:
        wrong_files = test_mounts(CRYFS_MAP)
        print wrong_files
        # By Default, we mount everything and check it
    else:
        not_mounted = mount_all(CRYFS_MAP)
        wrong_files = test_mounts(CRYFS_MAP)
        log.debug(not_mounted)
        log.error(wrong_files)
