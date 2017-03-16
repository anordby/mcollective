##
## THIS FILE IS UNDER PUPPET CONTROL. DON'T EDIT IT HERE.
##
## $Id: postfix.ddl 8409 2013-11-11 23:20:14Z itannord $

metadata :name => "Get information about Postfix config",
             :description => "Get info about Postfix main.cf config",
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
