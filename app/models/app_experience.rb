class AppExperience < ApplicationRecord

  ONBOARDING = 'onboarding'
  VALID_NAMES = [ONBOARDING]

  belongs_to :user

  validates :name, inclusion: { in: AppExperience::VALID_NAMES }
  validates :user_id, presence: true

  validates_uniqueness_of :name, scope: :user_id


  # def valid_name?(name)
  #   AppExperience.names.include? name
  # end

  def self.sample_name
    AppExperience::VALID_NAMES.sample
  end
end
