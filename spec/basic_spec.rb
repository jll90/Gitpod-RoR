require 'rails_helper'

RSpec.describe "Test suite", :type => :request do

  context 'when the test is correct' do
    it 'works for the right reasons' do
      expect(1 + 1).to eq(2)
    end

    it 'fails for the right reasons' do
      expect(1 + 1).to eq(1)
    end
  end
end