##
## THIS FILE IS UNDER PUPPET CONTROL. DON'T EDIT IT HERE.
##
## $Id: postfix.rb 9687 2014-01-22 13:40:32Z itannord $

# TODO:
# detect if Postfix is installed by Puppet?
# check if main.cf is a resource
# server ignore list mx/postmann etc

module MCollective
    module Agent
        # Collect info about Postfix configs in order to merge them into a
	# centralized config without breaking things
        class Postfix<RPC::Agent
            require 'mcollective/util/puppet_agent_mgr'
            
            action "getparams" do
              facts = PluginManager["facts_plugin"].get_facts
              uparams = Array.new
              cfile = "/etc/postfix/main.cf"
              m = Util::PuppetAgentMgr.manager
              if File.exist?(cfile)
                if m.managing_resource?("File[/etc/postfix/main.cf]")
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
                  ppair = line.split(/\s*=\s*/)
                  value = ppair.last.sub(/\s+$/, "")
                  key = ppair.first
                  next if key == "smtpd_banner"
                  next if key == "biff"
                  next if key == "append_dot_mydomain"
                  next if key == "fallback_relay"
                  next if key == "readme_directory"
                  next if key == "smtpd_use_tls"

                  # Parse mydestination list
                  if key == "mydestination"
                    mydests = Array.new
                    dests = value.split(/,\s+/)
                    dests.each do |dest|
                      next if dest == facts["fqdn"]
                      next if dest == facts["hostname"]
                      next if dest == "localhost"
                      next if dest == "localhost.localdomain"
                      next if dest == "localhost." + facts["domain"]
                      mydests.push(dest)
                    end
                    unless mydests.empty?
                      uparams.push("mydestination = " + mydests.join(","))
                    end
                    next
                  end

                  # Parse inet_interfaces list
                  if key == "inet_interfaces"
                    myints = Array.new
                    ints = value.gsub(/,/, '').split(/\s+/)
                    ints.each do |int|
                      next if int == "all"
                      next if int == "loopback-only"
                      next if int == facts["ipaddress"]
                      next if int == "127.0.0.1"
                      myints.push(int)
                    end
                    unless myints.empty?
                      uparams.push("inet_interfaces = " + myints.join(","))
                    end
                    next
                  end

                  # Parse mynetworks list
                  if key == "mynetworks"
                    mynets = Array.new
                    # no comma used in mynetworks?
                    nets = value.split(/\s+/)
                    nets.each do |net|
                      next if net == "127.0.0.0/8"
                      next if net == "[::ffff:127.0.0.0]/104"
                      next if net == "[::1]/128"
                      mynets.push(net)
                    end
                    unless mynets.empty?
                      uparams.push("mynetworks = " + mynets.join(","))
                    end
                    next
                  end

                  next if key == "inet_protocols" and value == "ipv4"
                  next if key == "myhostname" and value == facts ["fqdn"]
                  next if key == "mailbox_size_limit" and value == "0"
                  next if key == "smtpd_tls_cert_file" and value == "/etc/ssl/certs/ssl-cert-snakeoil.pem"
                  next if key == "smtp_tls_session_cache_database" and value == 'btree:${queue_directory}/smtp_scache'
                  next if key == "smtpd_tls_session_cache_database" and value == 'btree:${queue_directory}/smtpd_scache'
                  next if key == "smtp_tls_session_cache_database" and value == 'btree:${data_directory}/smtp_scache'
                  next if key == "smtpd_tls_session_cache_database" and value == 'btree:${data_directory}/smtpd_scache'
                  next if key == "recipient_delimiter" and value == "+"
                  next if key == "myorigin" and value == "/etc/mailname"
                  next if key == "myorigin" and value == facts["fqdn"]
                  next if key == "relayhost" and value.match(/^mx\d*\.(aftenposten|schibsted-it)\.no$/)
                  next if key == "alias_database" and value == "hash:/etc/aliases"
                  next if key == "alias_maps" and value == "hash:/etc/aliases"
                  next if key == "smtpd_tls_key_file" and value == "/etc/ssl/private/ssl-cert-snakeoil.key"
                  next if key == "smtpd_tls_cert_file" and value == "/etc/ssl/private/ssl-cert-snakeoil.pem"

                  uparams.push(key + " = " + value)
                end

                if uparams.empty?
                  reply.statusmsg = "OK"
                else
                  reply[:unexpected_params] = uparams
                  reply.fail "FAIL"
                end
              else
                reply.fail "No Postfix main.cf found"
              end
            end
        end
    end
end
