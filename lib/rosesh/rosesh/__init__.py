import multiprocessing
import os
import logging
from logging.config import fileConfig
import sys
import tempfile
import getpass
from llnl.util.filesystem import *
import llnl.util.tty as tty

#-----------------------------------------------------------------------------
# Variables describing how ROSE-SH is laid out in its prefix.
#-----------------------------------------------------------------------------
# This file lives in $prefix/lib/rosesh/rosesh/__file__
rosesh_root = ancestor(__file__, 4)

# The rosesh script itself
rosesh_file = join_path(rosesh_root, "bin", "rosesh")

# rosesh directory hierarchy
lib_path       = join_path(rosesh_root, "lib", "rosesh")
external_path  = join_path(lib_path, "external")
build_env_path = join_path(lib_path, "env")
module_path    = join_path(lib_path, "rosesh")
platform_path  = join_path(module_path, 'platforms')
compilers_path = join_path(module_path, "compilers")
build_systems_path = join_path(module_path, 'build_systems')
operating_system_path = join_path(module_path, 'operating_systems')
test_path      = join_path(module_path, "test")
hooks_path     = join_path(module_path, "hooks")
var_path       = join_path(rosesh_root, "var", "rosesh")
stage_path     = join_path(var_path, "stage")
repos_path     = join_path(var_path, "repos")
share_path     = join_path(rosesh_root, "share", "rosesh")

# Paths to built-in ROSE-SH repositories.
packages_path      = join_path(repos_path, "builtin")
mock_packages_path = join_path(repos_path, "builtin.mock")

# User configuration location
user_config_path = os.path.expanduser('~/.rosesh')

prefix = rosesh_root
opt_path       = join_path(prefix, "opt")
etc_path       = join_path(prefix, "etc")

#-----------------------------------------------------------------------------
# Logging
#-----------------------------------------------------------------------------
fileConfig(os.path.join(module_path, 'logging_config.ini'))
logger = logging.getLogger(__name__)
logger.debug('often makes a very good meal of %s', 'visiting tourists')

#-----------------------------------------------------------------------------
# Initial imports (only for use in this file -- see __all__ below.)
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# Initialize various data structures & objects at the core of ROSE-SH.
#-----------------------------------------------------------------------------
# Version information
rosesh_version = "0.0.1"

# Set up the default packages database.
#try:
#    repo = rosesh.repository.RepoPath()
#    sys.meta_path.append(repo)
#except rosesh.error.ROSE-SHError as e:
#    tty.die('while initializing ROSE-SH RepoPath:', e.message)

#-----------------------------------------------------------------------------
# config.yaml options
#-----------------------------------------------------------------------------
#_config = rosesh.config.get_config('config')


#-----------------------------------------------------------------------------
# When packages call 'from rosesh import *', this extra stuff is brought in.
#
# ROSE-SH internal code should call 'import rosesh' and accesses other
# variables (rosesh.repo, paths, etc.) directly.
#
# TODO: maybe this should be separated out to build_environment.py?
# TODO: it's not clear where all the stuff that needs to be included in
#       packages should live.  This file is overloaded for rosesh core vs.
#       for packages.
#
#-----------------------------------------------------------------------------
__all__ = []

#from rosesh.package import Package, run_before, run_after, on_package_attributes
#from rosesh.build_systems.makefile import MakefilePackage
#from rosesh.build_systems.autotools import AutotoolsPackage
#from rosesh.build_systems.cmake import CMakePackage
#from rosesh.build_systems.waf import WafPackage
#from rosesh.build_systems.python import PythonPackage
#from rosesh.build_systems.r import RPackage
#from rosesh.build_systems.perl import PerlPackage

__all__ += [
]

# Add default values for attributes that would otherwise be modified from
# ROSE-SH main script
debug = True
rosesh_working_dir = None
