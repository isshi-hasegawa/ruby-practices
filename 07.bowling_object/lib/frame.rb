# frozen_string_literal: true

class Frame
  attr_reader :frame_score
  private attr_reader :first_shot, :second_shot, :third_shot # rubocop:disable Style/AccessModifierDeclarations

  def initialize(first_mark, second_mark, third_mark = nil)
    @first_shot = Shot.new(first_mark)
    @second_shot = Shot.new(second_mark)
    @third_shot = Shot.new(third_mark)
    @frame_score = calc_frame_score
  end

  def strike?
    first_shot.score == 10
  end

  private

  def spare?
    [first_shot, second_shot].map(&:score).sum == 10
  end

  def calc_frame_score
    shots = [first_shot, second_shot]
    shots << third_shot if strike? || spare?
    shots.map(&:score).sum
  end
end
