##
## THIS FILE IS UNDER PUPPET CONTROL. DON'T EDIT IT HERE.
##
## $Id: limits.rb 9565 2014-01-16 10:48:02Z itannord $

module MCollective
    module Agent
        class Limits<RPC::Agent
            require 'mcollective/util/puppet_agent_mgr'
            
            action "getparams" do
              facts = PluginManager["facts_plugin"].get_facts
              uparams = Array.new
              cfile = "/etc/security/limits.conf"
              m = Util::PuppetAgentMgr.manager
              if File.exist?(cfile)
                if m.managing_resource?("File[/etc/security/limits.conf]")
                  if File.readlines(cfile).grep(/THIS FILE IS UNDER PUPPET CONTROL/).any?
                    reply.statusmsg = "OK, already managed."
                    return 0
                  else
                    reply.fail "Managed, but we are not replacing this. Ignoring parameters."
                    return 1
                  end
                end

                File.open(cfile).each_line do |line|
                  next if line.match(/^(#|$)/)
                  cline = line.split(/\s+/)

	          domain = cline[0]
	          type = cline[1]
	          item = cline[2]
	          value = cline[3]

                  next if domain == "*" and item == "nofile" and value.to_i <= 50000
                  next if domain == "root" and type == "soft" and item == "nofile" and value.to_i <= 65536
                  next if domain == "root" and type == "hard" and item == "nofile" and value.to_i <= 131072

                  # Standard Finn.no AS setting
                  next if facts["fqdn"].match(/\.(finn|finntech)\.no$/) and domain == "finn" and item == "nofile" and value.to_i == 8192

                  uparams.push(domain + " " + type + " " + item + " " + value)
                end

                if uparams.empty?
                  reply.statusmsg = "OK"
                else
                  reply[:unexpected_params] = uparams
                  reply.fail "FAIL"
                end
              else
                reply.fail "No /etc/security/limits.conf"
              end
            end
        end
    end
end
