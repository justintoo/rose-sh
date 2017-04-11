#!/bin/python

import argparse
import os
import subprocess
import sys
import difflib
import filelock
import filecmp
import sqlite3

#------------------------------------------------------------------------------
# Environment
#------------------------------------------------------------------------------
abs_srcdir 	= os.environ.get('application_abs_srcdir') + '/'
rose_database 	= abs_srcdir + 'rose-results.db'
rose_failures 	= abs_srcdir + 'rose-failures.txt'
rose_passes 	= abs_srcdir + 'rose-passes.txt'
cwd             = os.getcwd()

#------------------------------------------------------------------------------
# Database Handling
#------------------------------------------------------------------------------
def db__save_file_status(filename, directory, passed, commandline):
  print >> sys.stdout, "\n[INFO] Saving to database %s: '%s', '%s', '%d', '%s'" % (rose_database, filename, directory, passed, commandline)
  conn = sqlite3.connect(rose_database)
  c = conn.cursor()

  c.execute('''CREATE TABLE IF NOT EXISTS results
               (filename text, directory text, passed BOOLEAN, commandline text)''')

  c.execute("INSERT INTO results VALUES (?, ?, ?, ?)", (filename, directory, passed, commandline))
  conn.commit()
  conn.close()

#------------------------------------------------------------------------------
# CLI
#------------------------------------------------------------------------------
from optparse import OptionParser
parser = argparse.ArgumentParser()

def IsCxxFile(arg):
  if arg.endswith('.C') or arg.endswith('.cxx') or arg.endswith('.cpp'):
      return arg

def IsCFile(arg):
  if arg.endswith('.c') or arg.endswith('.cc'):
      return arg

def IsFortran(arg):
  if arg.endswith('.f') or arg.endswith('.f77') or arg.endswith('.f90'):
      return arg

def IsObject(arg):
  if arg.endswith('.o'):
      return arg

def IsHeader(arg):
  if arg.endswith('.h'):
      return arg

cc = os.environ.get('SYSTEM_CC')
cxx = os.environ.get('SYSTEM_CXX')
flags = os.environ.get('ROSESH_FLAGS')

print >> sys.stdout, "[INFO] SYSTEM_CC=%s" % (cc)
print >> sys.stdout, "[INFO] SYSTEM_CXX=%s" % (cxx)

#--------------------------------------
# --tool <toolname>
#--------------------------------------
tool_option = '--tool'
parser.add_argument(tool_option, action="store", default="identityTranslator", help="ROSE tool to process application")
options, unknown = parser.parse_known_args()

if options.tool:
  # Don't pass this option on to the tool, see http://stackoverflow.com/questions/35733262/is-there-any-way-to-instruct-argparse-python-2-7-to-remove-found-arguments-fro
  sys.argv = sys.argv[:1] + unknown
  tool = options.tool
else:
  print >> sys.stderr, "[FATAL] --tool <toolname> was not specified"
  exit(10)

#--------------------------------------
# filenames
#--------------------------------------
filenames = []
for arg in unknown:
  if IsCFile(arg) or IsCxxFile(arg) or IsFortran(arg) or IsObject(arg) or IsHeader(arg):
    filenames.append(os.path.basename(arg))

  if IsCFile(arg):
    default_compiler = cc
  elif IsCxxFile(arg):
    default_compiler = cxx

# Escape single quotes to retain them in commandline to tool
args = ' '.join("'%s'" % arg.replace("'", "\\'") for arg in sys.argv[1:])

# [ROSE-788] Could not open specified input file: TC_ARCH_X64
args = args.replace("'-D' 'TC_ARCH_X64'", "'-DTC_ARCH_X64'")

#------------------------------------------------------------------------------
# Main Execution
#------------------------------------------------------------------------------
try:
  cmd = '%s %s %s' % (tool, args, flags)
  print >> sys.stdout, '+', cmd
  retcode = subprocess.call(cmd, shell=True)

  # Try to run the original commandline with the default compiler
  if retcode == 1:
    print >> sys.stdout, '[ERROR] Failed requested tool commandline, trying to keep going with the default compiler next...'

    cmd = '%s %s %s' % (default_compiler, args, flags)
    print >> sys.stdout, '+', cmd
    retcode = subprocess.call(cmd, shell=True)

    # The default compiler should be able to compile this file. If not, terminate with a fatal error.
    if retcode == 1:
      print >> sys.stdout, '[FATAL] Default compiler commandline failed - can this file even be compiled?'
      exit(1)

    # Still want to log a failure, even though we "kept going"
    retcode = 1

  try:
      #------------------------------------------------------------------------
      # Get file name
      #------------------------------------------------------------------------
      #try:
      #  filenames = subprocess.check_output('%s --list-filenames %s' % (options.tool, args), shell=True)
      #except subprocess.CalledProcessError as e:
      #  print >> sys.stderr, "[FATAL] Failed to list filenames with %s" % (options.tool)
      #  print >> sys.stderr, e
      #  exit(e.returncode)
          
      #------------------------------------------------------------------------
      # Save result
      #------------------------------------------------------------------------
      if filenames == None or not filenames:
        print >> sys.stderr, "[FATAL] No filenames found"
        exit(1)
      else:
        for original_filename in filenames:
          print >> sys.stdout, '[INFO] Saving result to database for file:', original_filename
          if retcode == 0:
            db__save_file_status(original_filename, cwd, 1, cmd)
            print >> sys.stdout, '[RESULT] File passed:', original_filename
          else:
            db__save_file_status(original_filename, cwd, 0, cmd)
            print >> sys.stdout, '[RESULT] File failed:', original_filename
  except OSError as e:
    print >> sys.stderr, "Execution failed (1):", e
    exit(1)
except OSError as e:
  print >> sys.stderr, "Execution failed (2):", e
  exit(1)

