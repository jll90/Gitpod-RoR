require 'rails_helper'

RSpec.describe Validations::PhoneNumber do
  describe "Phone number validation" do
    m = Validations::PhoneNumber

    it "succeeds for a correct number" do
      result = m.validate("56940234906")
      expect(result).to be true
    end

    it "fails for incorrect prefix" do
      result = m.validate("55940234906")
      expect(result).to be false
    end

    it "fails for incorrect length" do
      result = m.validate("5594023490")
      expect(result).to be false
    end

    it "fails if nil" do
      result = m.validate("5594023490")
      expect(result).to be false
    end
  end
end
