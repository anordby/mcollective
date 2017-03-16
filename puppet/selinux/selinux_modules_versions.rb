# selinux_module_versions.rb
# Return list of installed SeLinux modules and versions to make it possible
# to avoid running SeLinux commands when not necessary

# Anders Nordby <anders@fupp.net>
# 2017-03-13

Facter.add("selinux_module_versions") do
	confine :kernel => "Linux"
	setcode do
		mversions = {}
		Dir.glob("/usr/share/selinux/*.te") do |tfile|
			mtext = File.open(tfile).read
			mline = mtext.gsub(/.*?^(module \S+ \S+).*/m, '\1')
			next if mtext == mline
			mdata = mline.split(/\s+/)
			mname = mdata[1]
			mversion = mdata[2].gsub(/;/, "")
			mversions[mname] = mversion
		end
		mversions
	end
end
