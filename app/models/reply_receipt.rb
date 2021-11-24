class ReplyReceipt < ApplicationRecord
  belongs_to :user
  belongs_to :reply
  has_one :question, through: :reply

  after_initialize :on_init
  def on_init
    return unless self.new_record?
    read = false
  end

  def self.user_unread_receipts(user_id)
    ReplyReceipt.where(user_id: user_id).select { |rr| rr.unread? }
  end

  def self.group_by_question(rrs)
    rrs.group_by{ |rr| rr.question.id }
  end

  def unread?
    !read
  end

  def read?
    read
  end

  ## nil would imply that the resource is read
  ## and that there is no point in rewriting the instance
  def mark_as_read
    return nil if new_record? || read?
    self.update(read: true)
  end

  ## nil would imply that the resource is unread
  ## and that there is no point in rewriting the instance
  def mark_as_unread
    return nil if new_record? || unread?
    self.update(read: false)
  end
end
