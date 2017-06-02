module RollHelpers

  def roll_each(object, rolls)
    rolls.each {|pins| object.send(:roll, pins) }
  end

  def roll_strike(object)
    roll_each object, [10]
  end

  def roll_spare(object)
    roll_each object, [3, 7]
  end
end

RSpec.configure do |c|
  c.include RollHelpers
end
