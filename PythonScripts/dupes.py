#/bin/env python
'''
Script to find and remove duplicated files
Based on http://pythoncentral.io/finding-duplicate-files-with-python/
'''

# Import everything needed
import os
import sys
import hashlib

def hashfile(path, blocksize=65536):
    '''
    Returns hash of a given file
    '''
    afile = open(path, 'rb')
    hasher = hashlib.md5()
    buf = afile.read(blocksize)
    while len(buf) > 0: #pylint: disable=C1801
        hasher.update(buf)
        buf = afile.read(blocksize)
    afile.close()
    return hasher.hexdigest()

def find_duplicate(parentfolder):
    '''
    Returns the duplicated files found in a given folder
    '''
    # Dups in format {hash:[names]}
    duplicates = {}
    for dirname, subdirs, filelist in os.walk(parentfolder):
        print 'Scanning %s...' % dirname
        for filename in filelist:
            # Get the path to the file
            path = os.path.join(dirname, filename)
            # Calculate hash
            file_hash = hashfile(path)
            # Add or append the file path
            if file_hash in duplicates:
                duplicates[file_hash].append(path)
            else:
                duplicates[file_hash] = [path]
    return duplicates

def joindicts(dict1, dict2):
    '''
    Joins two dictionaries
    '''
    for key in dict2.keys():
        if key in dict1:
            dict1[key] = dict1[key] + dict2[key]
        else:
            dict1[key] = dict2[key]

def printResults(dict1):
    results = list(filter(lambda x: len(x) > 1, dict1.values()))
    if results:
        print 'Duplicates Found:'
        print '___________________'
        for result in results:
            for subresult in result:
                print '\t\t%s' % subresult
            print '___________________'

    else:
        print 'No duplicate files found.'


if __name__ == '__main__':
    if len(sys.argv) > 1:
        dups = {}
        folders = sys.argv[1:]
        for i in folders:
            # Iterate the folders given
            if os.path.exists(i):
                # Find the duplicated files and append them to the dups
                joindicts(dups, find_duplicate(i))
            else:
                print '%s is not a valid path, please verify' % i
                sys.exit()
        printResults(dups)
    else:
        print 'Usage: python dupFinder.py folder or python dupFinder.py folder1 folder2 folder3'
