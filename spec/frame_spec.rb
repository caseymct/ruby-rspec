require 'spec_helper'

RSpec.describe Frame do
  let(:frame) { Frame.new }

  describe '#roll' do

    shared_examples_for 'a frame' do

      describe 'with rolls left' do
        it 'adds the next rolls to the current frame' do
          rolls.each do |pins|
            expect {
              frame.roll pins
            }.to change { frame.rolls.length }.by(1)
          end

          expected_score = rolls.reduce(:+) + (has_bonus ? 10 : 0)
          expect(frame.score).to eq expected_score
        end
      end

      describe 'with no rolls left' do
        it 'does not allow another roll' do
          roll_each frame, rolls

          expect { frame.roll(5) }.to_not change { frame.rolls.length }
        end
      end
    end

    describe 'without a bonus' do
      it_should_behave_like 'a frame' do
        let(:rolls) { [3, 4] }
        let(:has_bonus) { false }
      end
    end

    describe 'with a strike' do
      before(:each) { roll_strike frame }

      it_behaves_like 'a frame' do
        let(:rolls) { [3, 4] }
        let(:has_bonus) { true }
      end
    end

    describe 'with a spare' do
      before(:each) { roll_spare frame }

      it_behaves_like 'a frame' do
        let(:rolls) { [3] }
        let(:has_bonus) { true }
      end
    end
  end

  describe '#score' do
    it 'returns the sum of the rolls' do
      expect { frame.roll 3 }.to change { frame.score }.from(0).to(3)
      expect { frame.roll 4 }.to change { frame.score }.from(3).to(7)
    end

    it 'returns 0 if no rolls have been made' do
      expect(frame.score).to eq 0
    end
  end

  describe '#should_advance_frame?' do
    context 'without a bonus' do
      it 'returns true once there have been two rolls' do
        expect { frame.roll 3 }.to_not change { frame.should_advance_frame? }
        expect { frame.roll 4 }.to change { frame.should_advance_frame? }.from(false).to(true)
      end
    end

    context 'with a bonus' do
      context 'when not on the last frame' do
        it 'returns true for a strike' do
          expect {
            roll_strike frame
          }.to change { frame.should_advance_frame? }.from(false).to(true)
        end

        it 'returns true for a spare' do
          expect {
            roll_spare frame
          }.to change { frame.should_advance_frame? }.from(false).to(true)
        end
      end

      context 'when on the last frame' do
        before(:each) { frame.index = 10 }

        it 'returns false for a strike' do
          expect { roll_strike frame }.to_not change { frame.should_advance_frame? }
          expect { frame.roll 3 }.to_not change { frame.should_advance_frame? }
          expect { frame.roll 4 }.to_not change { frame.should_advance_frame? }
        end

        it 'returns false for a spare' do
          expect { roll_spare frame }.to_not change { frame.should_advance_frame? }
          expect { frame.roll 3 }.to_not change { frame.should_advance_frame? }
        end
      end
    end
  end

  describe '#has_max_rolls?' do

    def test_two_rolls
      expect { frame.roll 3 }.to_not change { frame.has_max_rolls? }
      expect { frame.roll 3 }.to change { frame.has_max_rolls? }.from(false).to(true)
    end

    context 'without a bonus' do
      it 'is true for two rolls' do
        test_two_rolls
      end
    end

    context 'with a bonus' do
      it 'is true for a strike and two additional rolls' do
        roll_strike frame
        test_two_rolls
      end

      it 'is true for a spare and an additional roll' do
        roll_spare frame
        expect { frame.roll 3 }.to change { frame.has_max_rolls? }.from(false).to(true)
      end
    end
  end
end
