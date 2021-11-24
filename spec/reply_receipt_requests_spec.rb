require 'rails_helper'

RSpec.describe "Reply Receipt Requests", :type => :request do
  describe "Reply Receipt Updates" do
    operations = [
      "read",
      "unread"
    ].each do |operation|
      it "can mark as #{operation}" do
        reply = create(:reply)
        reply_receipt = reply.reply_receipts.first
        reply_receipt.update(read: operation != "read")

        token = create(:token, user: reply_receipt.user)

        url = "/api/replies/#{reply.id}/reply_receipts.json?operation=#{operation}"
        patch url, headers: RequestsHelpers.build_headers(token.key)
        expect(response.status).to eq 200

        patch url, headers: RequestsHelpers.build_headers(token.key)
        expect(response.status).to eq 409
      end
    end
  end
end