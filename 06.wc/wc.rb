#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def main(option)
  if ARGV[0] # 引数がある場合は引数を受け取る
    word_count(option)
  else
    # 引数がない場合は標準出力を受け取る
    word_count_with_standard_input(option)
  end
end

def word_count(option)
  total_lines = 0
  total_words = 0
  total_bytesize = 0
  ARGV.each do |file|
    text = File.read(file)
    ary = to_array(text)
    output_formatted_array(ary, option)
    puts " #{file}"
    total_lines += lines(text)
    total_words += words(text)
    total_bytesize += bytesize(text)
  end
  return unless ARGV[1]

  output_formatted_array([total_lines, total_words, total_bytesize], option)
  puts ' total'
end

def word_count_with_standard_input(option)
  ary = to_array($stdin.read)
  output_formatted_array(ary, option)
  print "\n"
end

def lines(text)
  text.lines.size
end

def words(text)
  text.split(/\s+|　+/).size
end

def bytesize(text)
  text.bytesize
end

def to_array(text)
  ary = []
  ary << lines(text)
  ary << words(text)
  ary << bytesize(text)
  ary
end

def output_formatted_array(ary, option)
  print ary[0].to_s.rjust(8)
  return if option['l'] # -lオプションが指定されていない場合

  print ary[1].to_s.rjust(8)
  print ary[2].to_s.rjust(8)
end

option = ARGV.getopts('l')
main(option)
