class custom::selinux {
	# Enforce using puppet/selinux from Forge
	class { ::selinux:
		mode => 'enforcing'
	}
	# Clean up stale .te files
	tidy {
		"stale-selinux-te-files":
			path	=> "/usr/share/selinux",
			recurse	=> true,
			matches	=> ["*.te"],
			age	=> "7d",
			type	=> mtime,
		;
	}

	define addmodule (
		$version = undef,
	) {
		Selinux::Module {
			prefix		=> "",
			ensure		=> present,
		}
		if has_key($selinux_module_versions, $name) {
			$oldversion = $selinux_module_versions[$name]
			if $version == undef {
				notify {"Addmodule: Not trying to update $name, version not specified.":}
				$install_module = 0
			} elsif versioncmp($version, $oldversion) > 0 {
				notify {"Addmodule: Update module $name, version $version exists, newer than $oldversion.":}
				$install_module = 1
			} else {
#				notify {"Addmodule: Not updating module $name, version $oldversion is up to date with $version.":}
				$install_module = 0
			}
		} else {
			notify {"Addmodule: Install new module $name.":}
			$install_module = 1
		}
		if $install_module == 1 {
			selinux::module {
				$name:
					source		=> "puppet:///modules/custom/common/etc/selinux/targeted/modules/${name}.te",
				;
			}
		}
	}
}
