
# frozen_string_literal: true

class Api::RepliesController < BaseApiController
  before_action :authenticate_request

  def create
    success = ProductCreateQuestionReplyRequest.call(current_user, params).result
    success == true ? json_success(success, 201) : json_error(success)
  end

  def index
    ## get all replies where user has replied
    ## gives participation in threads
    replies = Reply.includes(:question, :reply_receipts).where(user_id: current_user.id)
    replies.each { |r| r.current_user_id = current_user.id }
    render json: RecordsPagination.call(replies, nil, nil, { include: %i[question], methods: %i[read] }).result
  end

  def delete
    success = ProductDeleteQuestionReplyRequest.call(current_user, params).result
    success == true ? json_success : json_error(success)
  end
end
