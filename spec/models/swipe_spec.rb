require 'rails_helper'

RSpec.describe Swipe, type: :model do
  describe "Swipe" do
    it "Raises an error when upserting one's own product" do
      product = create(:product)

      expect{ Swipe.upsert(product.owner.id, product, rand(0..1) == 1) }.to raise_error(ArgumentError)
    end

    it "Can upsert with no previous matches" do
      user = create(:user)
      product = create(:product)

      swipe = Swipe.upsert(user.id, product, true)
      expect(swipe).to be_truthy
      expect(swipe.find_match).to be_truthy

      another_product = create(:product)

      swipe = Swipe.upsert(user.id, another_product, false)
      expect(swipe).to be_truthy
      expect(swipe.find_match).to be_nil
    end

    it "It can upsert upon preexisting swipe" do
      existing_swipe = create(:swipe)

      liked = rand(0..1) == 1
      swipe = Swipe.upsert(existing_swipe.user.id, existing_swipe.product, liked)
      expect(swipe).to be_truthy
    end
  end
end
