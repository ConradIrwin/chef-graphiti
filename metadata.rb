name             "graphiti"
maintainer       "David Whittington"
maintainer_email "djwhitt@gmail.com"
license          "Apache 2.0"
description      "Installs/Configures graphiti"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"

%w{apache2 logrotate}.each do |cookbook|
  depends cookbook
end
