#!/usr/bin/env ruby

require 'rubygems'
require 'json'
require 'open-uri'

ghstatus = JSON.parse(open('https://status.github.com/api/status.json').read)['status']

if ghstatus == 'good'
  puts 'OK - GitHub runs smoothly'
  exit 0
else
  puts 'WARNING - GitHub is having issues :('
  exit 1
end