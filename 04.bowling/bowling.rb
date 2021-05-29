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
  next_frame = frames[i + 1]
  next_next_frame = frames[i + 2]

  point += frame.sum # 共通の処理
  if frame[0] == 10 && next_frame[0] == 10 # ダブルの場合の加算処理
    point += next_frame[0] + next_next_frame[0]
  elsif frame[0] == 10 # ストライクの場合の加算処理
    point += next_frame.sum
  elsif frame.sum == 10 # スペアの場合の加算処理
    point += next_frame[0]
  end
end

puts point
