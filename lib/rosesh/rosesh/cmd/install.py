import os
import logging
logger = logging.getLogger(__name__)

import subprocess
import rosesh
import spack

description = "install the ROSE compiler infrastructure"

COMPILER_DEFAULT = "gcc@4.8.5"
BOOST_DEFAULT = "boost@1.57.0"

def setup_parser(subparser):
    subparser.add_argument(
        'rose_version', nargs='?', default='master',
        help='install ROSE')

    subparser.add_argument(
        '--compiler', nargs='1', default='',
        help='compiler to compile ROSE with')


def bootstrap_repo():
    # Add Spack to the PATH so we can execute it
    current_env = os.environ.copy()
    current_env["PATH"] = rosesh.spack_bin_path + ":" + current_env["PATH"]

    # Add our custom ROSESH/repo to Spack's site-specific repo list;
    # Don't re-add if already added, else Spack will fail with an error
    roots = spack.config.get_config('repos', 'site')

    repo_added = False
    for r in roots:
        try:
            repo = spack.repository.Repo(r)
            if repo.namespace =='rosesh' and repo.root == rosesh.repo_path:
                repo_added = True
        except spack.repository.RepoError:
            continue

    if repo_added:
        logger.debug('already added our custom rosesh spack repository: %s' % (rosesh.repo_path))
    else:
        cmd = "spack repo add --scope=site %s" % (rosesh.repo_path)
        subprocess.call(cmd.split(), env=current_env)

def install(parser, args, unknown_args):
    bootstrap_repo()

    # Add Spack to the PATH so we can execute it
    current_env = os.environ.copy()
    current_env["PATH"] = rosesh.spack_bin_path + ":" + current_env["PATH"]

    # Execute the ROSE installation shell script:
    #
    #   $ install-rose.sh <rose_version> [args]
    #
    install_script = os.path.join(rosesh.bin_path, "install-rose.sh")
    subprocess.call([install_script, args.rose_version] + unknown_args, env=current_env)

