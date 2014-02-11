##
## THIS FILE IS UNDER PUPPET CONTROL. DON'T EDIT IT HERE.
##
## $Id: motd.ddl 9278 2014-01-03 13:46:07Z itannord $

metadata :name => "Get information about motd",
             :description => "Get info about motd contents",
             :author => "Anders Nordby",
             :license => "BSD",
             :version => "0.1",
             :url => "http://anders.fupp.net",
             :timeout => 60

action "getlines", :description => "Get list of unexpected lines" do
    display :ok

    output :unexpected_lines,
           :description => 'List of unexpected lines',
           :display_as => "Unexpected lines"
end
