# frozen_string_literal: true

class Frame
  attr_reader :frame_score

  def initialize(first_mark, second_mark, third_mark = nil)
    @first_shot = Shot.new(first_mark)
    @second_shot = Shot.new(second_mark)
    @third_shot = Shot.new(third_mark)
  end

  def frame_score
    shots = [first_shot, second_shot]
    shots << third_shot if strike_or_spare?
    shots.map(&:score).sum
  end

  private

  attr_reader :first_shot, :second_shot, :third_shot

  def strike_or_spare?
    first_shot.score == 10 || [first_shot, second_shot].map(&:score).sum == 10
  end
end
