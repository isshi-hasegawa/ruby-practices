# frozen_string_literal: true

require_relative 'args'
require_relative 'file'

module Ls
  class Formatter
    COLUMN_COUNT = 3

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

    private attr_reader :args # rubocop:disable Style/AccessModifierDeclarations

    def initialize
      @args = Ls::Args.new
    end

    def format
      args.long? ? format_long : format_short
    end

    private

    def format_long
      files = collect_files
      total_blocks = "total #{files.map(&:blocks).sum}"
      max_lengths = %i[nlink user group size].to_h { |key| [key, find_max_length(files, key)] }
      rows = collect_file_data(files).map { |data| format_row(data, max_lengths) }
      [total_blocks, rows].join("\n")
    end

    def format_short
      files = collect_files
      max_basename_length = find_max_length(files, :basename)
      file_names = files.map { |file| file.basename.ljust(max_basename_length) }

      remainder = files.length % COLUMN_COUNT
      (COLUMN_COUNT - remainder).times { file_names << [''] } unless remainder.zero?

      row_count = file_names.length / COLUMN_COUNT
      file_names.each_slice(row_count).to_a.transpose.map { |row| row.join("\t") }
    end

    def collect_files
      pattern = args.pathname
      params = args.all? ? [pattern, ::File::FNM_DOTMATCH] : [pattern]
      file_paths = Dir.glob(*params).sort
      args.reverse? ? file_paths.reverse! : file_paths
      file_paths.map { |path| Ls::File.new(path) }
    end

    def find_max_length(files, column)
      collect_file_data(files).map { |data| data[column] }
                              .max_by(&:length)
                              .length
    end

    def collect_file_data(files)
      files.map { |file| build_data(file) }
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

    def format_row(data, max_lengths)
      [
        data[:type_and_mode],
        data[:nlink].rjust(max_lengths[:nlink] + 1),
        data[:user].ljust(max_lengths[:user] + 1),
        data[:group].ljust(max_lengths[:group] + 1),
        data[:size].rjust(max_lengths[:size]),
        data[:mtime],
        data[:basename]
      ].join(' ')
    end
  end
end
