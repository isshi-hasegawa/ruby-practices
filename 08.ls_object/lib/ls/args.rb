# frozen_string_literal: true

require 'optparse'
require 'pathname'

module Ls
  class Args
    attr_reader :pathname
    private attr_reader :options # rubocop:disable Style/AccessModifierDeclarations

    def initialize
      @options = {}
      OptionParser.new do |opt|
        opt.on('-a') { |v| @options[:a] = v }
        opt.on('-l') { |v| @options[:l] = v }
        opt.on('-r') { |v| @options[:r] = v }
        opt.parse!(ARGV)
      end
      path = ARGV[0] || '.'
      @pathname = Pathname(path).join('*')
    end

    def all?
      options[:a]
    end

    def long?
      options[:l]
    end

    def reverse?
      options[:r]
    end
  end
end
