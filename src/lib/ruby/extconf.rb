require 'mkmf-rice'

$INCFLAGS += " -I/var/lib/gems/2.1.0/rice-2.1.0"
$CPPFLAGS += " -std=c++11"

puts "$INCFLAGS: #{$INCFLAGS}"
puts "$CPPFLAGS: #{$CPPFLAGS}"
create_makefile('dotstar')

