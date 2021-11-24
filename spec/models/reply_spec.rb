require 'rails_helper'

RSpec.describe Reply, type: :model do
  describe 'Reply rendering' do
    it 'can render json notification payload' do
      reply = create(:reply)
      expect(reply.as_notification_json).to be_truthy
    end
  end

  describe 'Reply creation' do
    it 'can create a valid reply' do
      question = create(:question)
      user = create(:user)

      reply = question.replies.new(
        content: 'Foo',
        user_id: user.id
      )

      expect(reply.valid?).to eq true
      expect{reply.save}.to change(Reply, :count).by(1)
      reply_receipts = reply.reply_receipts
      ## two reply receipts for product owner and user
      ## who posted the reply
      expect(reply_receipts.length).to eq 2
    end

    it 'it creates corresponding reply receipts' do
      reply = create(:reply)

      members = reply.question.members

      expect(members.length).to eq(3)
      expect(members.length - reply.reply_receipts.length).to eq(1)

      reply = create(:reply, question: reply.question)
      members = reply.question.members

      expect(members.length).to eq(4)
      expect(members.length - reply.reply_receipts.length).to eq(1)
    end
  end
end

