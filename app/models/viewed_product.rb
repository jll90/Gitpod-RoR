class Swipe < ApplicationRecord
  belongs_to :user
  belongs_to :product

  validates :user_id, uniqueness: { scope: :product_id }
  validates :liked, inclusion: [true, false]
end
