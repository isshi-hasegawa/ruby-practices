# frozen_string_literal: true

require_relative 'args'
require_relative 'file'

module Ls
  class Output
    COLUMN = 3

    private attr_reader :args, :files # rubocop:disable Style/AccessModifierDeclarations

    def initialize
      @args = Ls::Args.new
      @files = file_paths.map { |path| Ls::File.new(path) }
    end

    def run
      puts args.long_format? ? output_long_format : output
    end

    private

    def file_paths
      pattern = args.pathname
      params = args.all? ? [pattern, ::File::FNM_DOTMATCH] : [pattern]
      file_paths = Dir.glob(*params).sort
      args.reverse? ? file_paths.reverse! : file_paths
    end

    def total_blocks
      "total #{files.map(&:stat).map(&:blocks).sum}"
    end

    def find_max_column_length(column)
      files.map(&column).max_by(&:length).length
    end

    def format_row(file, column, additional_space = 0, direction = :rjust)
      width = find_max_column_length(column) + additional_space
      file.send(column).to_s.send(direction, width)
    end

    def rows
      files.map do |file|
        [
          format_row(file, :filetype_and_permissions),
          format_row(file, :hard_link_size),
          format_row(file, :owner_name, 0, :ljust),
          format_row(file, :group_name, 1),
          format_row(file, :byte_size, 1),
          format_row(file, :modified_time),
          format_row(file, :basename, 0, :ljust)
        ].join(' ')
      end
    end

    def output_long_format
      [total_blocks, rows].join("\n")
    end

    def remainder
      files.length % COLUMN
    end

    def output
      file_paths = files.map { |file| format_row(file, :basename, 0, :ljust) }
      file_paths << [''] * (COLUMN - remainder) unless remainder.zero?
      row_count = file_paths.length / COLUMN
      file_paths.each_slice(row_count).to_a.transpose.map { |row| row.join("\t") }
    end
  end
end
