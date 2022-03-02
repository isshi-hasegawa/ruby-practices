# frozen_string_literal: true

require_relative 'args'
require_relative 'file'

module Ls
  class Output
    COLUMN = 3

    FILETYPES = {
      'fifo' => 'p',
      'characterSpecial' => 'c',
      'directory' => 'd',
      'blockSpecial' => 'b',
      'file' => '-',
      'link' => 'l',
      'socket' => 's'
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

    private attr_reader :args, :files # rubocop:disable Style/AccessModifierDeclarations

    def initialize
      @args = Ls::Args.new
      @files = collect_file_paths.map { |path| Ls::File.new(path) }
    end

    def run
      puts args.long_format? ? output_long_format : output
    end

    private

    def collect_file_paths
      pattern = args.pathname
      params = args.all? ? [pattern, ::File::FNM_DOTMATCH] : [pattern]
      file_paths = Dir.glob(*params).sort
      args.reverse? ? file_paths.reverse! : file_paths
    end

    def total_blocks
      "total #{files.map(&:blocks).sum}"
    end

    def build_data(file)
      {
        type_and_mode: FILETYPES[file.file_type] + file.permission_number.gsub(/\d/, PERMISSIONS),
        nlink: file.hard_link_size.to_s,
        user: file.owner_name,
        group: file.group_name,
        size: file.byte_size.to_s,
        mtime: file.modified_time.strftime('%b %e %H:%M'),
        basename: file.basename
      }
    end

    def find_max_length(column)
      files.map { |file| build_data(file)[column] }
           .max_by(&:length)
           .length
    end

    def format_row(data, max_nlink, max_user, max_group, max_size)
      [
        data[:type_and_mode],
        data[:nlink].rjust(max_nlink + 1),
        data[:user].ljust(max_user + 1),
        data[:group].ljust(max_group + 1),
        data[:size].rjust(max_size),
        data[:mtime],
        data[:basename]
      ].join(' ')
    end

    def rows
      max_lengths = %i[nlink user group size].map do |key|
        find_max_length(key)
      end
      files.map do |file|
        data = build_data(file)
        format_row(data, *max_lengths)
      end
    end

    def output_long_format
      [total_blocks, rows].join("\n")
    end

    def remainder
      files.length % COLUMN
    end

    def output
      file_names = files.map { |file| format_row(file) }
      (COLUMN - remainder).times { file_names << [''] } unless remainder.zero?
      row_count = file_names.length / COLUMN
      file_names.each_slice(row_count).to_a.transpose.map { |row| row.join("\t") }
    end
  end
end
