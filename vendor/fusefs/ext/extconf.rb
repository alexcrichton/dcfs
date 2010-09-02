# extconf.rb for Ruby FuseFS
#

# This uses mkmf
require 'mkmf'

if RUBY_VERSION =~ /1.9/
  $CFLAGS << ' -DRUBY_19'
end

# This allows --with-fuse-dir, --with-fuse-lib, 
dir_config('fuse')

$CFLAGS << ' -I/usr/local/include'

# Make sure FUSE is found.
unless have_library('fuse') 
  puts "No FUSE library found!"
  exit
end

# OS X boxes have statvfs.h instead of statfs.h
have_header('sys/statvfs.h')
have_header('sys/statfs.h')

# Ensure we have the fuse lib.
create_makefile('fusefs_lib')
