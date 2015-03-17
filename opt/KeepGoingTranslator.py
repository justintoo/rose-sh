#!/usr/bin/env python

import argparse
import os
import subprocess
import sys
import difflib
import filelock

import sqlite3

abs_srcdir = os.environ.get('application_abs_srcdir') + '/'

def db__save_file_status(filename, passed, commandline):
  print >> sys.stdout, "\n[INFO] Saving to database: '%s', '%d', '%s'" % (filename, passed, commandline)
  db = abs_srcdir + 'rose-results.db'
  conn = sqlite3.connect(db)
  c = conn.cursor()

  c.execute('''CREATE TABLE IF NOT EXISTS results
               (filename text, passed BOOLEAN)''')

  c.execute("INSERT INTO results VALUES ('%s', %d)" % (filename, passed))
  conn.commit()
  conn.close()


from optparse import OptionParser
parser = argparse.ArgumentParser()
diffoption = '--diff'
parser.add_argument(diffoption, action="store_true", default=False, help="diff the original source file and the unparsed file")
options, unknown = parser.parse_known_args()

if options.diff:
  print >> sys.stdout, "\n[INFO] diffmode enabled for KeepGoingTranslator.py"
  sys.argv.remove(diffoption)

args = ' '.join("'%s'" % arg.replace("'", "\\'") for arg in sys.argv[1:])

rose_failures = abs_srcdir + 'rose-failures.txt'
rose_passes = abs_srcdir + 'rose-passes.txt'

try:
  #cmd = 'KeepGoingTranslator %s --strip-path-prefix="%s" --report-fail="%s" --report-pass="%s"' % (args, abs_srcdir, rose_failures, rose_passes)
  cmd = 'identityTranslator %s' % (args)
  print >> sys.stdout, '+', cmd

  retcode = subprocess.call(cmd, shell=True)

  try:
    filenames = subprocess.check_output('KeepGoingTranslator --list-filenames %s' % (args), shell=True)
  except subprocess.CalledProcessError as e:
    print >> sys.stderr, "[FATAL] Failed to list filenames"
    print >> sys.stderr, e
    exit(e.returncode)
    # TOO1 (20150203): Hack for Xen
    #exit(0)

  if retcode == 0:
    for original_filename in filenames.split():
      db__save_file_status(original_filename, 1, cmd)
  else:
#      print >> sys.stderr, "Child was terminated by signal", retcode
#      exit(retcode)
    try:
        if filenames == None or not filenames:
          print >> sys.stderr, "[FATAL] No filenames found"
          exit(1)
        else:
          for original_filename in filenames.split():
              db__save_file_status(original_filename, 0, cmd)
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
  print >> sys.stderr, "Execution failed:", e
  exit(1)

if options.diff:
  try:
      try:
        filenames = subprocess.check_output('KeepGoingTranslator --list-filenames %s' % (args), shell=True)
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
          print >> sys.stdout, "+ diff ", original_filename, unparsed_filename
  
          try:
            diff = subprocess.check_output('diff %s %s' % (original_filename, unparsed_filename), shell=True, stderr=subprocess.STDOUT)
          except subprocess.CalledProcessError as e:
            print >> sys.stderr, e.output
            print >> sys.stderr, e

            # --keep-going after diff, save failed file
            lock = filelock.FileLock(rose_failures)
            try:
              with lock.acquire(timeout=30):
                  with open(rose_failures, 'a+') as file:
                    print >> sys.stderr, "[ERROR] File failed %s, writing to keep going failures file" % (original_filename), rose_failures
                    file.write(original_filename + '\n')
            except filelock.Timeout as e:
              print >> sys.stderr, "[FATAL] Could not lock file for writing", rose_failures
              print >> sys.stderr, e
              exit(e.returncode)
              
            #exit(e.returncode)
          else:
            print >> sys.stdout, "[INFO] Files are identical"
  except OSError as e:
    print >> sys.stderr, "Execution failed:", e
    exit(1)

