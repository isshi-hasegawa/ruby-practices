# frozen_string_literal: true

require_relative 'args'
require_relative 'file'

module Ls
  class Formatter
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

    private attr_reader :args # rubocop:disable Style/AccessModifierDeclarations

    def initialize
      @args = Ls::Args.new
    end

    def format
      args.long? ? format_long : format_short
    end

    private

    def collect_files
      pattern = args.pathname
      params = args.all? ? [pattern, ::File::FNM_DOTMATCH] : [pattern]
      file_paths = Dir.glob(*params).sort
      args.reverse? ? file_paths.reverse! : file_paths
      file_paths.map { |path| Ls::File.new(path) }
    end

    def total_blocks
      "total #{collect_files.map(&:blocks).sum}"
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
      collect_files.map { |file| build_data(file)[column] }
                   .max_by(&:length)
                   .length
    end

    def find_max_lengths
      %i[nlink user group size].map do |key|
        find_max_length(key)
      end
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
      max_lengths = find_max_lengths
      collect_files.map do |file|
        data = build_data(file)
        format_row(data, *max_lengths)
      end
    end

    def format_long
      [total_blocks, rows].join("\n")
    end

    def remainder
      collect_files.length % COLUMN
    end

    def format_short
      max_basename = find_max_length(:basename)
      file_names = collect_files.map { |file| file.basename.ljust(max_basename) }
      (COLUMN - remainder).times { file_names << [''] } unless remainder.zero?
      row_count = file_names.length / COLUMN
      file_names.each_slice(row_count).to_a.transpose.map { |row| row.join("\t") }
    end
  end
end
