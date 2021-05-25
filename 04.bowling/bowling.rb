#!/usr/bin/env ruby
# frozen_string_literal: true

scores = ARGV[0].split(',')
shots = []
scores.each do |s|
  if s == 'X'
    shots << 10
    shots << 0
  else
    shots << s.to_i
  end
end

frames = []
shots[0..17].each_slice(2) do |s|
  # 1~9フレーム目までを[[1, 2],[3, 4],[10, 0]..]のようにframesに格納
  frames << s
end

if shots[18] == 10 && shots[20] == 10 && shots[22] == 10 # 10フレーム目がターキー
  3.times { frames << [10, 0] }
elsif shots[18] == 10 && shots[20] == 10 # 10フレーム目がダブル
  2.times { frames << [10, 0] }
  frames << [shots[22], 0]
elsif shots[18] == 10 # 10フレーム目がストライク
  frames << [10, 0]
  frames << [shots[20], shots[21]]
elsif shots[18] + shots[19] == 10 # 10フレーム目の2投目がスペアの場合
  frames << [shots[18], shots[19]]
  frames << [shots[20], 0]
else
  frames << [shots[18], shots[19]]
end

point = 0
frames[0..9].each_with_index do |frame, i|
  point += if frame[0] == 10 && frames[i + 1][0] == 10 && frames[i + 2][0] == 10 # ターキーの場合
             30
           elsif frame[0] == 10 && frames[i + 1][0] == 10 # ダブルの場合
             20 + frames[i + 2][0]
           elsif frame[0] == 10 # ストライクの場合
             10 + frames[i + 1].sum
           elsif frame.sum == 10 # スペアの場合
             10 + frames[i + 1][0]
           else
             frame.sum
           end
end

puts point
