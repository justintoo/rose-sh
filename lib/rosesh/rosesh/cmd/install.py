import logging
logger = logging.getLogger(__name__)

import spack

description = "install the ROSE compiler infrastructure"

def setup_parser(subparser):
    subparser.add_argument(
        'install_command', nargs='?', default=None,
        help='install ROSE')

def install(parser, args):
    logger.debug('starting execution of install')

    """ROSE build configuration can override both spack defaults and site config."""
    spack.install(parser, args)

    logger.debug('ending execution of install')
