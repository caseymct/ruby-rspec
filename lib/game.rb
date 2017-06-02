require './frame'

class Game
  attr_accessor :frames, :frame_index

  def initialize
    @frame_index = 0

    @frames = []
    (1..10).each do |i|
      @frames << Frame.new({ index: i })
    end
  end

  def score
    @frames.map(&:score).reduce(:+)
  end

  def current_frame
    @frames[@frame_index]
  end

  def roll(pins)
    if pins < 0 || pins > 10
      puts "You must supply a roll between 0 and 10"

    elsif !is_complete?
      @frame_index += 1 if current_frame.should_advance_frame?
      (0..@frame_index).each do |i|
        @frames[i].roll pins
      end

      puts "On frame #{current_frame.index} - score #{score}"
    else
      puts "Game is over! Score is #{score}"
    end
  end

  def is_complete?
    current_frame.is_last_frame? && current_frame.has_max_rolls?
  end
end
