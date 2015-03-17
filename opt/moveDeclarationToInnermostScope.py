#!/usr/local/bin/python

import argparse
import os
import subprocess
import sys
import difflib
import filelock
import filecmp

abs_srcdir = os.environ.get('application_abs_srcdir') + '/'

from optparse import OptionParser
parser = argparse.ArgumentParser()
diffoption = '--diff'
parser.add_argument(diffoption, action="store_true", default=False, help="diff the original source file and the unparsed file")
options, unknown = parser.parse_known_args()

if options.diff:
  print >> sys.stdout, "\n[INFO] diffmode enabled for moveDeclarationToInnermostScope.py"
  sys.argv.remove(diffoption)

args = ' '.join("'%s'" % arg.replace("'", "\\'") for arg in sys.argv[1:])

rose_failures = abs_srcdir + 'rose-failures.txt'
rose_passes = abs_srcdir + 'rose-passes.txt'

try:
  # ------------------------
  # MAIN COMMAND EXECUTION
  # ------------------------
  cmd = 'moveDeclarationToInnermostScope %s' % (args)
  print >> sys.stdout, '+', cmd
  retcode = subprocess.call(cmd, shell=True)

  if retcode != 0:
#      print >> sys.stderr, "Child was terminated by signal", retcode
#      exit(retcode)
    try:
        try:
          filenames = subprocess.check_output('moveDeclarationToInnermostScope --list-filenames %s' % (args), shell=True)
        except subprocess.CalledProcessError as e:
          print >> sys.stderr, e
          exit(e.returncode)
            
        if filenames == None or not filenames:
          print >> sys.stderr, "[FATAL] No filenames found"
          exit(1)
        else:
          for original_filename in filenames.split():
              # --keep-going after failure, save failed file
              lock = filelock.FileLock(rose_failures)
              try:
                with lock.acquire(timeout=30):
                    with open(rose_failures, 'a+') as file:
                      print >> sys.stderr, "[ERROR] File failed %s, writing to keep going failures file: %s" % (original_filename, file), rose_failures
                      file.write(original_filename + '\n')
              except filelock.Timeout as e:
                print >> sys.stderr, "[FATAL] Could not lock file for writing", rose_failures
                print >> sys.stderr, e
                exit(e.returncode)
                
              #exit(e.returncode)
    except OSError as e:
      print >> sys.stderr, "Execution failed (1):", e
      exit(1)
except OSError as e:
  print >> sys.stderr, "Execution failed (2):", e
  exit(1)

if options.diff:
  try:
      try:
        filenames = subprocess.check_output('moveDeclarationToInnermostScope --list-filenames %s' % (args), shell=True)
      except subprocess.CalledProcessError as e:
        print >> sys.stderr, e
        exit(e.returncode)
          
      if filenames == None or not filenames:
        print >> sys.stderr, "[FATAL] No filenames found"
        exit(1)
      else:
        for original_filename in filenames.split():
          # TOO1 (2014/12/04): ARES unparsed files are in the current (build) directory under "rose-workspace"
          #unparsed_filename = os.path.join(os.path.dirname(original_filename), 'rose_' + os.path.basename(original_filename))
          unparsed_filename = 'rose_' + os.path.basename(original_filename)
          # TOO1 (2014/12/29): Create patch in current build directory; <filename.extension>.patch
          patch_filename = os.path.basename(original_filename) + '.patch'

          print >> sys.stdout, "+ diff ", original_filename, unparsed_filename
          try:
            if filecmp.cmp(original_filename, unparsed_filename):
              print >> sys.stdout, "[INFO] Files are identical: %s and %s" % (original_filename, unparsed_filename)
            else:
              try:
                # TOO1 (12/29/2014): Return true since a difference would raise an exception, but we already know the files differ
                diff = subprocess.check_output('diff %s %s || true' % (original_filename, unparsed_filename), shell=True, stderr=subprocess.STDOUT)
                with open(original_filename + '.rpatch', 'w+') as rose_patch:
                  print >> sys.stdout, diff
                  print >> sys.stdout, "[INFO] Writing diff to file %s" % (rose_patch.name)
                  rose_patch.write(diff)
              except subprocess.CalledProcessError as e:
                # Unexpected error
                print >> sys.stderr, e.output
                print >> sys.stderr, e
                exit(e.returncode)
          except OSError as e:
            print >> sys.stderr, "[WARN] File comparison failed: ", e
            # may not have an unparsed file
            #exit(1)
  except OSError as e:
    print >> sys.stderr, "Execution failed (3):", e
    exit(1)

