##
## THIS FILE IS UNDER PUPPET CONTROL. DON'T EDIT IT HERE.
##

# anders@fupp.net, 2014-01-07
# Walks through local motd to find odd lines that should be preserved before
# pushing out standardized motd

module MCollective
    module Agent
        # Collect info about Postfix configs in order to merge them into a
        # centralized config without breaking things
        class Motd<RPC::Agent
            require 'mcollective/util/puppet_agent_mgr'
            
            action "getlines" do
              facts = PluginManager["facts_plugin"].get_facts
              ulines = Array.new
              mfile = "/etc/motd"
              m = Util::PuppetAgentMgr.manager
              if File.exist?(mfile)
                if m.managing_resource?("File[/etc/motd]")
                  if File.readlines(mfile).grep(/managed by Schibsted IT/).any?
                    reply.statusmsg = "OK, already managed with template."
                    return 0
                  end
                end

                File.open(mfile).each_line do |line|
                  line = line.strip
                  next if line.match(/^(#|$)/)
                  next if line.match(/^Linux .* (x86_64|i686)$/)
                  next if line.match(/^The programs included with the Debian/)
                  next if line.match(/^the exact distribution terms for each program are/)
                  next if line.match(/^individual files in/)
                  next if line.match(/^Debian GNU.Linux comes with ABSOLUTELY NO WARRANTY/)
                  next if line.match(/^permitted by applicable law/)
                  next if line.match(/^This server is managed by Puppet./)
                  ulines.push(line)
                end

                if ulines.empty?
                  reply.statusmsg = "OK"
                  reply.statuscode = 0
                else
                  reply.statusmsg = "FAIL"
                  reply.statuscode = 1
                  reply[:unexpected_lines] = ulines
                  reply.fail "Found unexpected lines in motd"
                end
              else
                reply.fail "No /etc/motd file found"
              end
            end
        end
    end
end
