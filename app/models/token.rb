class Token < ApplicationRecord
  belongs_to :user
  before_save :generate_key

  validates :key, uniqueness: true

  def generate_key(length = 50)
    self.key = TokenGenerator.generate(length)
  end
end
