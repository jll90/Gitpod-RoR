class ProductDeleteQuestionReplyRequest
  prepend SimpleCommand

  def initialize(current_user, parameters)
    @current_user = current_user
    @parameters = parameters
  end

  def call
    perform
  end

  private

  attr_reader :current_user, :parameters

  def perform
    product = current_user.products.find(parameters[:id])
    question = product.questions.find(parameters[:question_id])
    reply = question.replies.find(parameters[:reply_id])
    if reply.destroy!
      true
    else
      reply.errors.full_messages
    end
  rescue ActiveRecord::RecordNotFound
    ['Record not found']
  end
end
