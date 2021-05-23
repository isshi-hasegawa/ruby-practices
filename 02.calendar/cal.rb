#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require 'optparse'
require 'paint' # 'gem install paint'

today = Date.today
options = ARGV.getopts('', "y:#{today.year}", "m:#{today.mon}")

year = options['y'].to_i
month = options['m'].to_i

first_day = Date.new(year, month)
last_day = Date.new(year, month, -1)
dates = (first_day..last_day)
full_month_name = first_day.strftime('%B')
spaces_before_first_day = ' ' * 3 * first_day.wday

puts "#{full_month_name} #{year}".center(21)
puts ' Su Mo Tu We Th Fr Sa'
print spaces_before_first_day
dates.each do |date|
  if date == today
    spaces_before_today = date.day < 10 ? ' ' * 2 : ' '
    print spaces_before_today + Paint[today.day, :inverse].to_s
  else
    print date.day.to_s.rjust(3)
  end
  print "\n" if date.saturday?
end
