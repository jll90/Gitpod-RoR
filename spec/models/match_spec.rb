require 'rails_helper'

RSpec.describe Match, type: :model do
  describe 'Match instantion' do
    it 'Values are set upon init' do
      match = Match.new

      expect(match.buyer_read).to eq(true)
      expect(match.user_read).to eq(false)
    end

    it 'Factory works' do
      match = create(:match)
      expect(match.user_id).to eq(match.product.user_id)
      expect(match.buyer_id).to be_truthy
      expect(match.user_id).to_not eq(match.buyer_id)
      expect(match.product_id).to be_truthy
      expect(match.buyer_product_id).to be_nil
    end
  end

  describe 'Match lifecycle' do
    it 'accepting match works' do
      match = create(:match)
      sender = match.sender
      product = sender.products.sample

      expect(match.just_transitioned_to_accepted?).to eq(false)
      match.accept!(product.id)
      expect(match.just_transitioned_to_accepted?).to eq(true)
      expect(match.state).to eq('accepted')
      expect(match.buyer_product_id).to eq(product.id)
      expect(match.buyer_read).to eq(false)
    end

    it 'confirming match works' do
      match = create(:match)
      sender = match.sender
      product = sender.products.sample
      match.accept!(product.id)
      expect(match.just_transitioned_to_confirmed?).to eq(false)
      match.confirm!
      expect(match.just_transitioned_to_confirmed?).to eq(true)
      expect(match.state).to eq('confirmed')
      expect(match.user_read).to eq(false)
    end
  end
end
