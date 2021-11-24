class Reply < ApplicationRecord
  include Loggable

  belongs_to :question
  belongs_to :user
  has_many :reply_receipts, dependent: :delete_all

  after_create :refresh_question_timestamp
  after_create :generate_reply_receipts

  validates :content, presence: true

  attr_accessor :current_user_id

  def other_participants
    all_users = question.members
    current_user = self.user
    all_users - [current_user]
  end

  ## Helper method to simply read/unread logic
  ## through read receipts
  def read
    raise "Reply: no current user when invoking read method" if @current_user_id.nil?
    ## we return nil if reply belongs to the same user
    ## meaning that the read state 
    ## is meaningless
    return nil if self.user_id == @current_user_id

    ## from here on we return either true or false
    ## to show whether reply has been seen by user

    receipts = self.reply_receipts
    receipt = receipts.find { |r| r.user_id == @current_user_id }
    receipt.read
  end

  def as_notification_json
    self.as_json({ include: [:question] })
  end

  def self.seed!
    users = User.all
    questions = Question.all
    
    questions.each do |q|
      q.replies.create!(content: Faker::Lorem.sentences.join(" "), user_id: users.sample.id)
    end
  end

  private

  def generate_reply_receipts
    receipt_users = self.other_participants
    receipt_users.map do |user|
      reply_receipt = self.reply_receipts.new(user_id: user.id)
      reply_receipt.save!
    end
  end

  def refresh_question_timestamp
    self.question.touch
  end

end
