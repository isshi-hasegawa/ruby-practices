# frozen_string_literal: true

require 'date'
require 'etc'

module Ls
  class File
    private attr_reader :path, :stat # rubocop:disable Style/AccessModifierDeclarations

    def initialize(path)
      @path = path
      @stat = ::File.lstat(@path)
    end

    def blocks
      stat.blocks
    end

    def file_type
      stat.ftype
    end

    def permission_numbers
      stat.mode.to_s(8)[-3..]
    end

    def hard_link_size
      stat.nlink
    end

    def owner_name
      Etc.getpwuid(stat.uid).name
    end

    def group_name
      Etc.getgrgid(stat.gid).name
    end

    def byte_size
      stat.size
    end

    def modified_time
      stat.mtime
    end

    def basename
      ::File.basename(path)
    end
  end
end
