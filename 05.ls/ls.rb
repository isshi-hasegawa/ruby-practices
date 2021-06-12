#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require 'etc'
require 'optparse'

def main(options)
  # カレントディレクトリの情報を取得する
  current_directory = Dir.glob('*')
  # -aオプションを指定されたら、ファイル名の先頭に'.'を含めた配列をcurrent_directoryに再代入する
  current_directory = Dir.glob('*', File::FNM_DOTMATCH) if options['a']
  # -rオプションを指定されたら、current_directoryの配列を逆順にする
  current_directory.reverse! if options['r']

  options['l'] ? list_segments_with_l_option(current_directory) : list_segments(current_directory)
end

# ファイルタイプを表す数字を記号に変換する
def convert_to_filetype(filetype_num)
  {
    '01': 'p',
    '02': 'c',
    '04': 'd',
    '06': 'b',
    '10': '-',
    '12': 'l',
    '14': 's'
  }[filetype_num.to_sym]
end

# パーミッションを表す数字を記号に変換する
def convert_to_permission(permission_num)
  {
    '0': '---',
    '1': '--x',
    '2': '-w-',
    '3': '-wx',
    '4': 'r--',
    '5': 'r-x',
    '6': 'rw-',
    '7': 'rwx'
  }[permission_num.to_sym]
end

def create_file_stat(file_name)
  File::Stat.new(Dir.pwd + "/#{file_name}")
end

if options['l']
  # totalを表示する
  total = 0
  current_directory.each do |file|
    file_stat = create_file_stat(file)
    total += file_stat.blocks
  end
  puts "total #{total}"

  # ファイルの詳細をターミナルに表示する
  current_directory.each do |file|
    file_stat = create_file_stat(file)
    mode_num = file_stat.mode.to_s(8).rjust(6, '0')
    print filetype = convert_to_filetype(mode_num[0..1])
    print owner_permission = convert_to_permission(mode_num[3])
    print group_permission = convert_to_permission(mode_num[4])
    print other_permission = convert_to_permission(mode_num[5])
    print num_of_hard_link = file_stat.nlink.to_s.rjust(4)
    print ' '
    print owner_name = Etc.getpwuid(file_stat.uid).name
    print ' ' * 2
    print group_name = Etc.getgrgid(file_stat.gid).name
    print file_size = file_stat.size.to_s.rjust(6)
    print month = file_stat.mtime.strftime('%-m').rjust(3)
    print date = file_stat.mtime.strftime('%-d').rjust(3)
    if Date.today.year == file_stat.mtime.year
      print time = file_stat.mtime.strftime('%R').rjust(6)
    else
      print year = file_stat.mtime.strftime('%Y').rjust(6)
    end
    print ' '
    print file
    print "\n"
  end
else
  # each_sliceに渡す引数を決める
  slice_number = current_directory.size / 3
  slice_number += 1 unless (current_directory.size % 3).zero?

  # current_directoryを3分割して配列にする
  sliced_array = current_directory.each_slice(slice_number).to_a

  # 配列の要素数を揃える
  (sliced_array[0].size - sliced_array[-1].size).times { sliced_array[-1].push('') } unless (current_directory.size % 3).zero?

  # 配列の行と列を入れ替える
  transposed_array = sliced_array.transpose

  # ' 'に乗算する数字を決める
  # 10はmacOSのlsコマンドの仕様から目測
  num_for_spaces = current_directory.max_by(&:size).size + 10

  # ターミナルに表示する
  transposed_array.each do |ary|
    print ary[0] + ' ' * (num_for_spaces - ary[0].size)
    print ary[1] + ' ' * (num_for_spaces - ary[1].size)
    print ary[2]
    print "\n"
  end
end

# オプションの指定を受け取る
options = ARGV.getopts('a', 'l', 'r')
main(options)
