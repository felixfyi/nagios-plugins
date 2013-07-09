#!/usr/bin/env ruby
# usage: ./check_memcache-bytes.rb -H HOSTNAME -p PORT -w WARNPERCENTAGE -c CRITPERCENTAGE
# example: ./check_memcache-bytes.rb -H localhost -p 11211 -w 75 -c 90

require 'rubygems'
require 'optparse'
require 'memcache'

params = {:host => 'localhost', :port => '11211', :warn => 75, :crit => 90}

parser = OptionParser.new do |opts|
  opts.banner = "Usage: #{__FILE__} [options]"
  opts.separator ''

  opts.on('-H', '--host HOST', String, 'Host to connect, default localhost')  { |h| params[:host] = h }
  opts.on('-p', '--port PORT', Integer, 'Memcache port, default 11211')       { |p| params[:port] = p }
  opts.on('-w', '--warn LEVEL', Integer, 'Warning level, default 75')         { |w| params[:warn] = w }
  opts.on('-c', '--critical LEVEL', Integer, 'Critical level, default 90')    { |c| params[:crit] = c }

  opts.on_tail('-h', '--help', 'Show this message') {
    puts opts
    exit
  }

  opts.parse!(ARGV)
end

server = "#{params[:host]}:#{params[:port]}"
warn = "#{params[:warn]}".to_i
crit = "#{params[:crit]}".to_i

stats = MemCache.new(server).stats[server]

limit_maxbytes = stats["limit_maxbytes"].to_i
bytes = stats["bytes"].to_i

used = ((bytes.to_f / limit_maxbytes.to_f) * 100)

if (used > crit)
  retval = 2
 elsif (used > warn)
  retval = 1
 else
  retval = 0
end

return_str = "bytes: #{bytes.to_i/1024000} MB limit_maxbytes: #{limit_maxbytes.to_i/1024000} MB"

stat_string = "memcache usage: #{used.round}% #{return_str}"

if ( retval == 0 )
    puts "OK - #{stat_string} \n"
    exit retval
  elsif ( retval == 1 )
    print "WARNING - #{stat_string} \n"
    exit retval
  elsif ( retval == 2 )
    print "CRITICAL - #{stat_string} \n"
    exit retval
end

exit retval
