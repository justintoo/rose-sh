#------------------------------------------------------------------------------
# Author: Justin Too <too1@llnl.gov>
#------------------------------------------------------------------------------

import os
from spack import *

class Rose(Package):
    """A compiler infrastructure to build source-to-source program
       transformation and analysis tools.
       (Developed at Lawrence Livermore National Lab)"""

    homepage = "http://rosecompiler.org/"
    url      = "https://github.com/rose-compiler/rose-develop"

    version('master', branch='master', git='https://github.com/rose-compiler/rose.git')
    # Placeholder for dynamic version
    #version('__ROSE_VERSION__', commit='__ROSE_COMMIT__', git='__ROSE_REPO__')

    depends_on("autoconf@2.69")
    depends_on("automake@1.14")
    depends_on("libtool@2.4")
    #depends_on("boost@1.55.0 %gcc@4.8.3")

    def install(self, spec, prefix):
        # Bootstrap with autotools
        bash = which('bash')
        bash('build')

        # Configure, compile & install
        with working_dir('rose-build', create=True):
            boost = spec['boost']

            configure = Executable(os.path.abspath('../configure'))
            configure("--prefix=" + prefix,
                      "--enable-edg_version=4.9",
                      "--without-java",
                      "--with-boost=" + boost.prefix,
                      "--disable-boost-version-check",
                      "--enable-languages=c,c++,binaries")
            make("install-core")

