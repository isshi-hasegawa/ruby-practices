# frozen_string_literal: true

class Game
  FRAME_NUMBER = 10

  def initialize(marks)
    @marks = marks.split(',')
  end

  def score
    frames = create_frames
    frames.map(&:frame_score).sum
  end

  private attr_reader :marks # rubocop:disable Style/AccessModifierDeclarations

  def strike?
    marks[0] == 'X'
  end

  def create_frames
    frames = []
    FRAME_NUMBER.times do
      frames << Frame.new(*marks[0..2])
      strike? ? marks.shift(1) : marks.shift(2)
    end
    frames
  end
end
