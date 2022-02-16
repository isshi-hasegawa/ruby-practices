# frozen_string_literal: true

class Shot
  attr_reader :score

  def initialize(mark)
    @score = parse_mark(mark)
  end

  private

  def parse_mark(mark)
    mark == 'X' ? 10 : mark.to_i
  end
end
