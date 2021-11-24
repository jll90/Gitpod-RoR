
# frozen_string_literal: true

class Api::ReplyReceiptsController < BaseApiController
  before_action :authenticate_request
  before_action :find_reply_receipt_from_reply_id, only: [:update]

  def update
    operation = params[:operation]
    result = @reply_receipt.send("mark_as_#{operation}")

    return head :conflict if result.nil?
    return head :ok if result

    head :internal_server_error
  end

  def find_reply_receipt_from_reply_id
    reply_receipts = ReplyReceipt.where(reply_id: params[:reply_id])
    return head :not_found if reply_receipts.empty?

    @reply_receipt = reply_receipts.find { |rr| rr.user_id == current_user.id }
    return head :forbidden if @reply_receipt.nil? 
  end
end
