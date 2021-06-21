#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def main(option)
  word_count(option)
  print_total(option) if ARGV[1]
end

def word_count(option)
  ARGV.each do |file|
    sentence = File.read(file)
    print sentence.lines.size.to_s.rjust(8)
    unless option['l']
      print sentence.split(/\s+|　+/).size.to_s.rjust(8)
      print sentence.bytesize.to_s.rjust(8)
    end
    puts " #{file}"
  end
end

def print_total(option)
  total_lines = 0
  total_words = 0
  total_bytesize = 0
  ARGV.each do |file|
    sentence = File.read(file)
    total_lines += sentence.lines.size
    total_words += sentence.split(/\s+|　+/).size
    total_bytesize += sentence.bytesize
  end
  print total_lines.to_s.rjust(8)
  unless option['l']
    print total_words.to_s.rjust(8)
    print total_bytesize.to_s.rjust(8)
  end
  puts ' total'
end

option = ARGV.getopts('l')
if ARGV[0] # 引数がある場合
  main(option)
else
  # 引数がない場合
  stdin = $stdin.read
  print stdin.lines.size.to_s.rjust(8)
  unless option['l'] # -lオプションが指定されていなければ
    print stdin.split(/\s+|　+/).size.to_s.rjust(8)
    print stdin.bytesize.to_s.rjust(8)
  end
  print "\n"
end
