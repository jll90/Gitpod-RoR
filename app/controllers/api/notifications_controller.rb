
# frozen_string_literal: true

class Api::NotificationsController < BaseApiController
  before_action :authenticate_request

  def index
    notifications = Notification.where(user_id: current_user.id)
    render json: notifications
  end

  def unread
    unread_reply_receipts = ReplyReceipt.user_unread_receipts(current_user.id)
    questions_count = ReplyReceipt.group_by_question(unread_reply_receipts).size

    matches_count = current_user.matches.reject { |m| m.user_read }.size + current_user.buyer_matches.reject { |m| m.buyer_read }.size

    render json: { 
      questions_count: questions_count,
      matches_count: matches_count,
      total_count: questions_count + matches_count
    }
  end
end
