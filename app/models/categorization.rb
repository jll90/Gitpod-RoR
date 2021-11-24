class Categorization < ApplicationRecord
  include AASM
  belongs_to :product
  belongs_to :category

  # after_initialize :on_init

  # def on_init
  #   self.state ||= :active
  # end

  aasm column: :state do
    state :active, initial: true
    state :deleted

    event :reset do
      transitions to: :active
    end

    event :delete do
      transitions from: :active, to: :deleted
    end
  end
end
