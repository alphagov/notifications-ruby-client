# Version numbering follows Semantic Versionning:
#
# Given a version number MAJOR.MINOR.PATCH, increment the:
# - MAJOR version when you make incompatible API changes,
# - MINOR version when you add functionality in a backwards-compatible manner, and
# - PATCH version when you make backwards-compatible bug fixes.
#
# -- http://semver.org/

module Notifications
  class Client
    VERSION = "5.1.2".freeze
  end
end
