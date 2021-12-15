require 'rails_helper'

RSpec.describe "Test suite", :type => :request do

  context 'User class' do
    it 'A user can be instantiated' do
      user = User.new
      expect(user.instance_of? User).to eq(true)
    end

    it 'the User info method returns an info string' do
      user = User.new
      expect(user.info).to be_a(String)
    end
  end
end