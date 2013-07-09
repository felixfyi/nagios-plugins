#!/usr/bin/env ruby
# check_php-fpm-status.rb
# usage: ./check_php-fpm.rb -H HOSTNAME -p PORT -s STATUSURL -w WARNPERCENTAGE -c CRITPERCENTAGE
# example: ./check_php-fpm.rb -H localhost -p 80 -s php-fpm-status-www -w 39 -c 49

require 'rubygems'
require 'optparse'
require 'open-uri'

params = {:host => 'localhost', :port => '80', :statuspage => 'php-fpm-status', :warn => 75, :crit => 90}

parser = OptionParser.new do |opts|
  opts.banner = "Usage: #{__FILE__} [options]"
  opts.separator ''

  opts.on('-H', '--host HOST', String, 'Host to connect, default localhost')                    { |h| params[:host] = h }
  opts.on('-p', '--port PORT', Integer, 'HTTP port, default 80')                                { |p| params[:port] = p }
  opts.on('-s', '--statuspage STATUSPAGE', String, 'Status page path, default php-fpm-status')  { |s| params[:statuspage] = s }
  opts.on('-w', '--warn LEVEL', Integer, 'Warning level, default 75')                           { |w| params[:warn] = w }
  opts.on('-c', '--critical LEVEL', Integer, 'Critical level, default 90')                      { |c| params[:crit] = c }

  opts.on_tail('-h', '--help', 'Show this message') {
    puts opts
    exit
  }

  opts.parse!(ARGV)
end

warn = "#{params[:warn]}".to_i
crit = "#{params[:crit]}".to_i

begin
status_url = open("http://#{params[:host]}:#{params[:port]}/#{params[:statuspage]}").read
formatted = status_url.split("\n").map{ |status_url| status_url.split(/: */) }

active_processes = formatted.find { |active_processes| active_processes[0]=="active processes" }[1].to_f
total_processes = formatted.find { |total_processes| total_processes[0]=="total processes" }[1].to_f
rescue
  print "CRITICAL - couldn't open php-fpm status URL \n"
  retval = 2
  exit retval
end

used = ((active_processes.to_f / total_processes.to_f) * 100)

if (used > crit)
  retval = 2
 elsif (used > warn)
  retval = 1
 else
  retval = 0
end

return_str = "php-fpm process usage: #{used.round}% active php-fpm processes: #{active_processes.to_i} maximum php-fpm processes (total): #{total_processes.to_i}"

if ( retval == 0 )
    puts "OK - #{return_str} \n"
    exit retval
  elsif ( retval == 1 )
    print "WARNING - #{return_str} \n"
    exit retval
  elsif ( retval == 2 )
    print "CRITICAL - #{return_str} \n"
    exit retval
end

exit retval
