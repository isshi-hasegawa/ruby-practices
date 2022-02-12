#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative('../lib/shot')
require_relative('../lib/frame')
require_relative('../lib/game')

puts Game.new(ARGV[0]).score if __FILE__ == $PROGRAM_NAME
