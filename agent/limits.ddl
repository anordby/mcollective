##
## THIS FILE IS UNDER PUPPET CONTROL. DON'T EDIT IT HERE.
##
## $Id: limits.ddl 9456 2014-01-13 08:43:24Z itannord $

metadata :name => "Get information about /etc/security/limits.conf",
             :description => "Get info about /etc/security/limits.conf",
             :author => "Anders Nordby",
             :license => "BSD",
             :version => "0.1",
             :url => "http://anders.fupp.net",
             :timeout => 60

action "getparams", :description => "Get list of unexpected params" do
    display :ok

    output :unexpected_params,
           :description => 'List of unexpected parameters',
           :display_as => "Unexpected parameters"
end
