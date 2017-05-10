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


def add_repo(namespace, root):
    # Add Spack to the PATH so we can execute it
    current_env = os.environ.copy()
    current_env["PATH"] = rosesh.spack_bin_path + ":" + current_env["PATH"]

    # Don't re-add repo if already added, else Spack will fail with an error
    roots = spack.config.get_config('repos', 'site')

    repo_added = False
    for r in roots:
        try:
            repo = spack.repository.Repo(r)
            if repo.namespace == namespace and repo.root == root:
                repo_added = True
        except spack.repository.RepoError:
            continue

    if repo_added:
        logger.debug('already added our custom spack repository: %s' % (root))
    else:
        cmd = "spack repo add --scope=site %s" % (root)
        subprocess.call(cmd.split(), env=current_env)

def create_temp_repo():
    # version('__ROSE_VERSION__', commit='__ROSE_COMMIT__', git='__ROSE_REPO__')
    replacements = {
        '__ROSE_VERSION__': rose_version,
        '__ROSE_COMMIT__': rose_commit,
        '__ROSE_REPO__': rose_repo
    }

    with open('path/to/input/file') as infile, open('path/to/output/file', 'w') as outfile:
        for line in infile:
            for src, target in replacements.iteritems():
                line = line.replace(src, target)
            outfile.write(line)

def install(parser, args, unknown_args):
    repo_namespace = 'rosesh'
    repo_path = rosesh.repo_path
    add_repo(repo_namespace, repo_path)

    # Add Spack to the PATH so we can execute it
    current_env = os.environ.copy()
    current_env["PATH"] = rosesh.spack_bin_path + ":" + current_env["PATH"]

    # Execute the ROSE installation shell script:
    #
    #   $ install-rose.sh <rose_version> [args]
    #
    install_script = os.path.join(rosesh.bin_path, "install-rose.sh")
    subprocess.call([install_script, args.rose_version] + unknown_args, env=current_env)

