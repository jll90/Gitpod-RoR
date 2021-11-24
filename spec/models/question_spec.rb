require 'rails_helper'

RSpec.describe Question, type: :model do
  describe 'Question creation' do
    it 'can create a valid question' do
      product = create(:product)
      user = create(:user)

      question = product.questions.new(
        content: 'Foo',
        user_id: user.id,
        addressee_id: product.owner.id
      )

      expect(question.valid?).to eq true
      expect{question.save}.to change(Question, :count).by(1)
      expect(question.replies.length).to eq 1
    end

    it 'the corresponding reply belongs to the same user' do
      question = create(:question)
      reply = question.replies.first
      expect(question.user_id).to eq reply.user_id
    end
  end

  describe 'Question rendering' do
    it 'can render json notification payload' do
      question = create(:question)
      expect(question.as_notification_json).to be_truthy
    end
  end

  describe 'Question members' do
    it 'works' do
      question = create(:question)
      members = question.members

      expect(members.length).to eq 2
    end
  end

  describe 'Question mark as read' do
    it 'works' do
      question = create(:question)

      (1..5).each do |_n|
        create(:reply, question: question)
      end

      user = question.addressee

      reply_receipts = question.reply_receipts
      user_reply_receipts = reply_receipts.select { |rr| rr.user_id == user.id }

      expect(user_reply_receipts.any? { |rr| rr.unread? }).to be_truthy
      question.mark_as_read(user.id)
      expect(user_reply_receipts.all? { |rr| rr.reload.read? }).to be_truthy
    end

    it 'raises for users not members' do
      question = create(:question)

      expect { question.mark_as_read(1000) }.to raise_error(ArgumentError)
    end
  end
end
