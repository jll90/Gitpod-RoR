class User < ApplicationRecord

  validates :name, presence: true
  validates :age, presence: true

  def info
    nil
  end
end
