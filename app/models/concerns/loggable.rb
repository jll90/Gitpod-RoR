module Loggable
  extend ActiveSupport::Concern

  included do
    has_many :logs, as: :loggable
    after_create :audit_create
    after_update :audit_update
    before_destroy :audit_destroy
  end

  def audit_create
    create_record('created')
  end

  def audit_update
    create_record('updated')
  end

  def audit_destroy
    create_record('destroyed')
  end

  def create_record(type)
    Log.create(loggable_id: self.id, loggable_type: self.class, event: "#{self.class.name.downcase}_#{type}")
  end
end
