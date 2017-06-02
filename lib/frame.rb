class Frame
  attr_accessor :index, :rolls

  def initialize(params = {})
    @index = params.fetch(:index, 0)
    @rolls = []
  end

  def roll(pins)
    @rolls << pins if can_roll?
  end

  def score
    @rolls.length > 0 ? @rolls.reduce(:+) : 0
  end

  def should_advance_frame?
    !is_last_frame? && (is_bonus? || has_max_rolls?)
  end

  def has_max_rolls?
    @rolls.length == max_rolls_for_frame
  end

  def is_last_frame?
    @index == 10
  end

  private

  def can_roll?
    @rolls.length < max_rolls_for_frame
  end

  def max_rolls_for_frame
    (is_strike? || is_spare?) ? 3 : 2
  end

  def is_bonus?
    is_strike? || is_spare?
  end

  def is_strike?
    @rolls[0] == 10
  end

  def is_spare?
    @rolls.length >= 2 && (@rolls[0] + @rolls[1]) == 10
  end
end
