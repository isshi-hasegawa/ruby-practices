# frozen_string_literal: true

class Game
  FRAME_NUMBER = 10
  private attr_reader :marks, :frames # rubocop:disable Style/AccessModifierDeclarations

  def initialize(marks)
    @marks = marks.split(',')
    @frames = create_frames
  end

  def score
    frames.map(&:frame_score).sum
  end

  private

  def create_frames
    frames = []
    FRAME_NUMBER.times do
      frame = Frame.new(*marks[0..2])
      frames << frame
      frame.strike? ? marks.shift(1) : marks.shift(2)
    end
    frames
  end
end
