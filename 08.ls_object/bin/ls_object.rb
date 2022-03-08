#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/ls/formatter'

puts Ls::Formatter.new.format
