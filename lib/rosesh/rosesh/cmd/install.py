import os
import logging
logger = logging.getLogger(__name__)

import subprocess
import rosesh

description = "install the ROSE compiler infrastructure"

def setup_parser(subparser):
    subparser.add_argument(
        'rose_version', nargs='?', default='master',
        help='install ROSE')

def install(parser, args, unknown_args):
    logger.debug('starting execution of install')

    current_env = os.environ.copy()
    current_env["PATH"] = rosesh.spack_bin_path + ":" + current_env["PATH"]

    # Execute the ROSE installation shell script:
    #
    #   $ install-rose.sh <rose_version> [args]
    #
    install_script = os.path.join(rosesh.bin_path, "install-rose.sh")
    subprocess.call([install_script, args.rose_version] + unknown_args, env=current_env)

    logger.debug('ending execution of install')
