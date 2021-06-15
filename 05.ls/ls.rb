#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require 'etc'
require 'optparse'

def main(options)
  # -aオプションが指定されたら、ファイル名の先頭に'.'を含めた配列をcurrent_directoryに格納する
  current_directory = options['a'] ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*')
  # -rオプションが指定されたら、current_directoryの配列を逆順にする
  current_directory.reverse! if options['r']
  # -lオプションが指定されたらファイルごとに詳細を表示し、指定されなかったらファイル名を3列で表示する
  options['l'] ? list_segments_with_l_option(current_directory) : list_segments(current_directory)
end

# カレントディレクトリの当該ファイルのFile::Statオブジェクトを生成する
def create_file_stat(file_name)
  File::Stat.new(File.join(Dir.pwd, file_name))
end

# ブロック数を合計する
def total_blocks(current_directory)
  current_directory.map { |file| create_file_stat(file).blocks }.sum
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

def list_segments_with_l_option(current_directory)
  # ブロック数の合計を表示する
  puts "total #{total_blocks(current_directory)}"
  # ファイルの詳細情報をターミナルに表示する
  current_directory.each do |file|
    file_stat = create_file_stat(file)
    # ファイルタイプとパーミッションを取得する
    mode_num = file_stat.mode.to_s(8).rjust(6, '0')
    filetype = convert_to_filetype(mode_num[0..1])
    owner_permission = convert_to_permission(mode_num[3])
    group_permission = convert_to_permission(mode_num[4])
    other_permission = convert_to_permission(mode_num[5])
    # ハードリンク数を取得する
    hard_link_num = file_stat.nlink.to_s.rjust(4)
    # オーナー名とグループ名を取得する
    owner_name = Etc.getpwuid(file_stat.uid).name
    group_name = Etc.getgrgid(file_stat.gid).name
    # ファイルサイズを取得する
    file_size = file_stat.size.to_s.rjust(6)
    # タイムスタンプを取得する
    mtime = file_stat.mtime
    month = mtime.strftime('%-m').rjust(3)
    date = mtime.strftime('%-d').rjust(3)
    time_or_year = Date.today.year == mtime.year ? mtime.strftime('%R').rjust(6) : mtime.strftime('%Y').rjust(6)
    # ターミナルに表示する
    print "#{filetype}#{owner_permission}#{group_permission}#{other_permission}#{hard_link_num} "
    print "#{owner_name}  #{group_name}#{file_size}#{month}#{date}#{time_or_year} #{file}"
    print "\n"
  end
end

def list_segments(current_directory)
  # 配列の要素数を揃える
  (3 - current_directory.size % 3).times { current_directory.push('') } if current_directory.size % 3
  # 配列を3分割し、行と列を入れ替える
  transposed_array = current_directory.each_slice(current_directory.size / 3).to_a.transpose
  # current_directoryで最も文字数の多い要素を求め、その文字数をnum_for_spacesに格納する
  num_for_spaces = current_directory.max_by(&:size).size
  # ターミナルに表示する
  transposed_array.each do |ary|
    print ary[0].ljust(num_for_spaces)
    print ary[1].ljust(num_for_spaces)
    print ary[2]
    print "\n"
  end
end

# オプションの指定を受け取る
options = ARGV.getopts('a', 'l', 'r')
main(options)
