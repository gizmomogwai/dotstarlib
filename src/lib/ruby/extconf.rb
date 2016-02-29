require 'mkmf-rice'

$INCFLAGS += " -I/home/pi/.rvm/gems/ruby-2.3.0@dotstarlib/gems/rice-2.1.0"
#$INCFLAGS += " -I/var/lib/gems/2.1.0/rice-2.1.0"
$CPPFLAGS += " -std=c++11"

puts "$INCFLAGS: #{$INCFLAGS}"
puts "$CPPFLAGS: #{$CPPFLAGS}"
create_makefile('dotstar')

