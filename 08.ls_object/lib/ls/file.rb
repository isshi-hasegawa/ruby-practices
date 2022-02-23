# frozen_string_literal: true

require 'date'
require 'etc'

module Ls
  class File
    FILETYPES = {
      '01' => 'p',
      '02' => 'c',
      '04' => 'd',
      '06' => 'b',
      '10' => '-',
      '12' => 'l',
      '14' => 's'
    }.freeze

    PERMISSIONS = {
      '0' => '---',
      '1' => '--x',
      '2' => '-w-',
      '3' => '-wx',
      '4' => 'r--',
      '5' => 'r-x',
      '6' => 'rw-',
      '7' => 'rwx'
    }.freeze

    attr_reader :stat
    private attr_reader :path, :mtime # rubocop:disable Style/AccessModifierDeclarations

    def initialize(path)
      @path = path
      @stat = ::File.lstat(@path)
      @mtime = @stat.mtime
    end

    def filetype_and_permissions
      mode_num = stat.mode.to_s(8).rjust(6, '0')
      file_type = mode_num[0..1].gsub(/\d{2}/, FILETYPES)
      permissions = mode_num[-3..].gsub(/\d/, PERMISSIONS)
      file_type + permissions
    end

    def hard_link_size
      stat.nlink.to_s
    end

    def owner_name
      Etc.getpwuid(stat.uid).name
    end

    def group_name
      Etc.getgrgid(stat.gid).name
    end

    def byte_size
      stat.size.to_s
    end

    def modified_time
      over_six_months_ago? ? mtime.strftime('%-m %e  %Y') : mtime.strftime('%-m %e %H:%M')
    end

    def basename
      ::File.basename(path)
    end

    private

    def over_six_months_ago?
      six_months_ago = Date.today << 6
      (six_months_ago <=> Date.parse(mtime.to_s)) == 1
    end
  end
end
