require 'mkmf'

if RUBY_VERSION =~ /1.9/
  $CFLAGS << ' -DRUBY_19'
end

$CFLAGS << ' -Wall'
$CFLAGS << ' -Werror'
$CFLAGS << ' -D_FILE_OFFSET_BITS=64'
$CFLAGS << ' -DFUSE_USE_VERSION=26'

$LDFLAGS << ' -lfuse'

if find_header('fuse.h', '/usr/include', '/usr/local/include')
  create_makefile('rfuse_ng')
else
  puts 'No FUSE install available'
end
