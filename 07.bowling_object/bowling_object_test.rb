# frozen_string_literal: true

require 'minitest/autorun'
require_relative('./shot')
require_relative('./frame')
require_relative('./game')

class BowlingObjectTest < MiniTest::Test
  def calc_score(marks)
    Game.new(marks).score
  end

  def test_calc1
    marks = '6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,6,4,5'
    assert_equal 139, calc_score(marks)
  end

  def test_calc2
    marks = '6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,X,X,X'
    assert_equal 164, calc_score(marks)
  end

  def test_calc3
    marks = '0,10,1,5,0,0,0,0,X,X,X,5,1,8,1,0,4'
    assert_equal 107, calc_score(marks)
  end

  def test_calc_all_zero
    marks = '0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0'
    assert_equal 0, calc_score(marks)
  end

  def test_calc_perfect
    marks = 'X,X,X,X,X,X,X,X,X,X,X,X'
    assert_equal 300, calc_score(marks)
  end
end
