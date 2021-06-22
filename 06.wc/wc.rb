#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def main(option)
  if ARGV[0] # 引数がある場合は引数を受け取る
    word_count(option)
    print_total(option) if ARGV[1]
  else
    # 引数がない場合は標準出力を受け取る
    word_count_with_standard_input(option)
  end
end

def word_count(option)
  ARGV.each do |file|
    ary = display_array(File.read(file))
    print_rjust(ary, option)
    puts " #{file}"
  end
end

def print_total(option)
  ary = []
  ary << ARGV.map { |file| to_lines(File.read(file)) }.sum
  ary << ARGV.map { |file| to_words(File.read(file)) }.sum
  ary << ARGV.map { |file| to_bytesize(File.read(file)) }.sum
  print_rjust(ary, option)
  puts ' total'
end

def word_count_with_standard_input(option)
  ary = display_array($stdin.read)
  print_rjust(ary, option)
  print "\n"
end

def to_lines(text)
  text.lines.size
end

def to_words(text)
  text.split(/\s+|　+/).size
end

def to_bytesize(text)
  text.bytesize
end

def display_array(text)
  ary = []
  ary << to_lines(text)
  ary << to_words(text)
  ary << to_bytesize(text)
  ary
end

def print_rjust(ary, option)
  print ary[0].to_s.rjust(8)
  return if option['l'] # -lオプションが指定されていない場合

  print ary[1].to_s.rjust(8)
  print ary[2].to_s.rjust(8)
end

option = ARGV.getopts('l')
main(option)
