# frozen_string_literal: true

class Shot
  attr_reader :score

  def initialize(mark)
    @score = parse_mark(mark)
  end

  private

  def parse_mark(mark)
    return 10 if mark == 'X'

    mark.to_i
  end
end
