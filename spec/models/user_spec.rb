require 'rails_helper'

RSpec.describe User, type: :model do
  describe "User" do
    it "validates a valid phone number" do
      user = User.new(phone: "56971333317")
      user.valid_number
      expect(user.errors).to be_empty
    end

    # it "generates auth token after creation" do
    #   user = create(:user)
    #   tokens = user.tokens
    #   expect(tokens.length).to eq(1)
    # end
  end
end
