require 'rails_helper'

RSpec.describe ReplyReceipt, type: :model do
  describe "Mark as read/unread" do
    it "returns nil for new records" do
      reply_receipt = ReplyReceipt.new
      expect(reply_receipt.mark_as_read).to be_nil
      expect(reply_receipt.mark_as_unread).to be_nil
    end

    it "returns true and then nil from there on if reading" do
      reply = create(:reply)
      reply_receipt = reply.reply_receipts.first
      
      expect(reply_receipt.mark_as_read).to be_truthy
      expect(reply_receipt.mark_as_read).to be_nil
    end

    it "returns true and then nil from there on if unreading" do
      reply = create(:reply)
      reply_receipt = reply.reply_receipts.first
      reply_receipt.update(read: true)
      
      expect(reply_receipt.mark_as_unread).to be_truthy
      expect(reply_receipt.mark_as_unread).to be_nil
    end
  end
end
