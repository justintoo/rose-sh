from __future__ import print_function

import os
import sys

import llnl.util.tty as tty
import rosesh
import inspect


class RoseShError(Exception):
    """This is the superclass for all RoseSh errors.
       Subclasses can be found in the modules they have to do with.
    """

    def __init__(self, message, long_message=None):
        super(RoseShError, self).__init__()
        self.message = message
        self._long_message = long_message

        # for exceptions raised from child build processes, we save the
        # traceback as a string and print it in the parent.
        self.traceback = None

    @property
    def long_message(self):
        return self._long_message

    def die(self):
        # basic debug message
        tty.error(self.message)
        if self.long_message:
            print(self.long_message)

        # stack trace, etc. in debug mode.
        if rosesh.debug:
            if self.traceback:
                # exception came from a build child, already got
                # traceback in child, so print it.
                sys.stderr.write(self.traceback)
            else:
                # run parent exception hook.
                sys.excepthook(*sys.exc_info())

        os._exit(1)

    def __str__(self):
        msg = self.message
        if self._long_message:
            msg += "\n    %s" % self._long_message
        return msg

    def __repr__(self):
        args = [repr(self.message), repr(self.long_message)]
        args = ','.join(args)
        qualified_name = inspect.getmodule(
            self).__name__ + '.' + type(self).__name__
        return qualified_name + '(' + args + ')'

    def __reduce__(self):
        return type(self), (self.message, self.long_message)


class UnsupportedPlatformError(RoseShError):
    """Raised by packages when a platform is not supported"""

    def __init__(self, message):
        super(UnsupportedPlatformError, self).__init__(message)


class NoNetworkConnectionError(RoseShError):
    """Raised when an operation needs an internet connection."""

    def __init__(self, message, url):
        super(NoNetworkConnectionError, self).__init__(
            "No network connection: " + str(message),
            "URL was: " + str(url))
        self.url = url


class SpecError(RoseShError):
    """Superclass for all errors that occur while constructing specs."""


class UnsatisfiableSpecError(SpecError):
    """Raised when a spec conflicts with package constraints.
       Provide the requirement that was violated when raising."""
    def __init__(self, provided, required, constraint_type):
        super(UnsatisfiableSpecError, self).__init__(
            "%s does not satisfy %s" % (provided, required))
        self.provided = provided
        self.required = required
        self.constraint_type = constraint_type
