rose-sh
=======

A shell framework to compile applications from out in the wild with the ROSE compiler, [http://rosecompiler.org/](http://rosecompiler.org/).

Usage
=====

See the `--help` information:

```bash
$ ./rose.sh --help
```

Here is an example commandline to test the Apache2 application:

```bash
ROSE_CC="KeepGoingTranslator" \
APACHE2_CONFIGURE_OPTIONS="--enable-mods-shared=\"foo\" --enable-mods-static=\"bar1 bar2\"" \
parallelism="24" \
        /usr/bin/time --format='%E' ./rose.sh apache2
```

Mirrors
========

Applications
------------

* Public: https://bitbucket.org/rose-compiler/<application_name>.git
* Private (LLNL): rose-dev@rosecompiler1.llnl.gov:rose/c/<application_name>.git

Dependencies
------------

* [https://bitbucket.org/rose-compiler/rose-sh/downloads](https://bitbucket.org/rose-compiler/rose-sh/downloads)
* [http://portal.nersc.gov/project/dtec/tarballs/dependencies](http://portal.nersc.gov/project/dtec/tarballs/dependencies)

