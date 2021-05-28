#!/usr/bin/env ruby
# frozen_string_literal: true

scores = ARGV[0].split(',')
shots = []
scores.each do |score|
  if score == 'X'
    shots << 10
    shots << 0
  else
    shots << score.to_i
  end
end

frames = []
shots.each_slice(2) do |shot|
  frames << shot
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
