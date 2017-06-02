require 'spec_helper'

RSpec.describe Game do
  let(:game) { Game.new }

  def init_no_bonus_rolls_array(frames, pins)
    [].tap do |rolls|
      (frames * 2).times { rolls << pins }
    end
  end

  def roll_each(rolls)
    rolls.each {|pins| game.roll(pins) }
  end

  def roll_strike
    game.roll 10
  end

  def roll_spare
    roll_each [3, 7]
  end

  def test_should_advance_frame(next_roll)
    expect(game.current_frame.should_advance_frame?).to be true

    expect {
      game.roll next_roll
    }.to change { game.current_frame.index }.by(1)
  end

  context 'before the game has started' do
    it 'should have a score of 0' do
      expect(game.score).to eq 0
    end

    it 'should have 10 frames' do
      expect(game.frames.length).to eq 10
    end

    it 'should be on the first frame' do
      expect(game.current_frame.index).to eq 1
    end
  end


  context 'first frame' do
    context 'with no strike or spare' do
      describe '#score' do
        let(:rolls) { [3, 6] }

        it 'returns the number of pins knocked down on the first roll' do
          expect {
            game.roll rolls[0]
          }.to change { game.score }.from(0).to(rolls[0])
        end

        it 'returns the total number of pins knocked down on the second roll' do
          expect {
            roll_each rolls
          }.to change { game.score }.from(0).to(rolls[0] + rolls[1])
        end
      end
    end

    context 'with a strike' do
      before(:each) { roll_strike }

      it 'should have a score of 10' do
        expect(game.score).to eq 10
      end

      it 'should advance the frame' do
        test_should_advance_frame 3
      end
    end

    context 'with a spare' do
      before(:each) { roll_spare }

      it 'should have a score of 10' do
        expect(game.score).to eq 10
      end

      it 'should advance the frame' do
        test_should_advance_frame 3
      end
    end
  end

  context 'advancing frames' do
    let(:first_frame_rolls) { [3, 6] }
    let(:first_frame_score) { first_frame_rolls.reduce(:+) }
    let(:next_frame_rolls) { [1, 7] }

    before(:each) { roll_each(first_frame_rolls) }

    context 'with no strike or spare' do

      describe 'first roll of next frame' do
        it 'should advance the frame' do
          test_should_advance_frame next_frame_rolls[0]
        end

        it 'should have a score of the combined rolls' do
          expect {
            game.roll next_frame_rolls[0]
          }.to change {
            game.score
          }.from(first_frame_score).to(first_frame_score + next_frame_rolls[0])
        end
      end

      describe 'second roll of next frame' do
        before(:each) { game.roll next_frame_rolls[0] }

        it 'should not advance the frame yet' do
          expect {
            game.roll next_frame_rolls[1]
          }.to_not change { game.current_frame.index }
        end

        it 'should have a score of the combined rolls' do
          score_before_roll = first_frame_score + next_frame_rolls[0]
          expect {
            game.roll next_frame_rolls[1]
          }.to change {
            game.score
          }.from(score_before_roll).to(score_before_roll + next_frame_rolls[1])
        end
      end
    end

    context 'with a strike' do
      before(:each) { roll_strike }

      it 'should advance the frame on the next roll' do
        test_should_advance_frame next_frame_rolls[0]
      end

      it 'should add the next two rolls to the strike frame score' do
        expect {
          game.roll next_frame_rolls[0]
        }.to change { game.score }.by(2*next_frame_rolls[0])

        expect {
          game.roll next_frame_rolls[1]
        }.to change { game.score }.by(2*next_frame_rolls[1])
      end

      it 'should work with multiple strikes' do
        # pins are added to the previous strike frame and the current frame
        expect { roll_strike }.to change { game.score }.by(20)

        pins = next_frame_rolls[0]
        # pins are added to the two strike frames and the current frame
        expect { game.roll(pins) }.to change { game.score }.by(3*pins)

        pins = next_frame_rolls[1]
        # pins are added to the last strike frame and the current frame
        expect { game.roll(pins) }.to change { game.score }.by(2*pins)
      end

      it 'should work with spares' do
        score_before_roll = first_frame_score + 10
        expected_score = first_frame_score + 10 + 2*3
        expect { roll_spare }.to change { game.score }.by(20)
      end
    end

    context 'with a spare' do
      before(:each) { roll_spare }

      it 'should advance the frame on the next roll' do
        test_should_advance_frame next_frame_rolls[0]
      end

      it 'should add the first roll of the current frame to the spare frame' do
        expect {
          game.roll next_frame_rolls[0]
        }.to change { game.score }.by(2*next_frame_rolls[0])

        expect {
          game.roll next_frame_rolls[1]
        }.to change { game.score }.by(next_frame_rolls[1])
      end
    end
  end

  context 'last frame' do
    let(:prior_rolls) { init_no_bonus_rolls_array(9, 3) }

    before(:each) { roll_each(prior_rolls) }

    def test_last_frame_score(last_frame_rolls)
      last_frame_rolls.each do |pins|
        expect { game.roll(pins) }.to change { game.score }.by(pins)
      end

      expect(game.score).to eq(prior_rolls.reduce(:+) + last_frame_rolls.reduce(:+))
    end

    def test_game_is_complete(last_frame_rolls)
      expect {
        roll_each last_frame_rolls
      }.to change { game.is_complete? }.from(false).to(true)
    end

    describe 'without a strike or spare' do
      let(:rolls) { [1, 7] }

      it 'treats the last frame like any other' do
        test_last_frame_score rolls
      end

      it 'marks the game as complete' do
        test_game_is_complete rolls
      end

      it 'does not allow a third roll' do
        roll_each rolls
        expect { game.roll 5 }.to_not change { game.score }
      end
    end

    [ { type: 'strike', rolls: [10, 1, 7] }, { type: 'spare', rolls: [5, 5, 7] } ].each do |data|
      describe "with a #{data[:type]}" do
        it 'allows three rolls' do
          test_last_frame_score data[:rolls]
        end

        it 'marks the game as complete' do
          test_game_is_complete data[:rolls]
        end

        it 'does not allow a third roll' do
          roll_each data[:rolls]
          expect { game.roll 5 }.to_not change { game.score }
        end
      end
    end
  end

  describe 'perfect game' do
    it 'has a score of 300' do
      rolls = init_no_bonus_rolls_array(10, 10) << 10
      expect { roll_each(rolls) }.to change { game.score }.to(300)
    end
  end
end
