Bits and pieces to improve performance loading SeLinux modules in Linux using
Puppet. Currently running many selinux commands for every Puppet runs is very
slow.

Loads .te files only when necessary, when a version number got updated. Checks
version info by scanning .te files from disk, and exposing it to Puppet as a
hash with SeLinux module version info.

Tested only in Red Hat.

Policyutils dropping version info from semanage module -l definetly does not
help.
