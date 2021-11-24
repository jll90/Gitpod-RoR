require 'rails_helper'

RSpec.describe "Swipe Requests", :type => :request do
  describe "Can create swipes" do
    it "it works" do
      product = create(:product)
      token = create(:token)

      liked = rand(0..1) == 1
      put "/api/swipes.json?liked=#{liked}&product_id=#{product.id}", headers: RequestsHelpers.build_headers(token.key)
      expect(response.status).to eq 201
    end
  end

  describe 'Destroy disliked swipes' do
    it 'it works' do
      token = create(:token)
      user = token.user

      create(:swipe, :disliked, user: user)

      expect(user.disliked_swipes.size).to eq(1)

      delete "/api/swipes/dislikes.json", headers: RequestsHelpers.build_headers(token.key)
      expect(response.status).to eq 200
      expect(user.disliked_swipes.size).to eq(0)
    end
  end
end
