class ProductCreateQuestionReplyRequest
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
    values = parameters.require(:body).permit(:content)
    question = Question.find(parameters[:question_id])
    reply = question.replies.new(user_id: current_user.id, content: values[:content])
    if reply.valid?
      reply.save
    else
      reply.errors.full_messages
    end
  rescue ActiveRecord::RecordNotFound
    ['Record not found']
  end
end
