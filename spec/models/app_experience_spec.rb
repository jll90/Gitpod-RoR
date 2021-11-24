require 'rails_helper'

RSpec.describe AppExperience, type: :model do
  describe "AppExperience" do

    it "is valid" do
      user = create(:user)
      ae = AppExperience.new(user_id: user.id, name: AppExperience.sample_name)
      expect(ae.valid?).to eq(true)
    end

    it 'cannot duplicate experience' do
      app_experience = create(:app_experience)

      expect {  
        app_experience = create(:app_experience, user: app_experience.user, name: app_experience.name)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
