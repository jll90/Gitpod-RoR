class ProductCreateQuestionRequest
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
    product = Product.find(parameters[:product_id])
    ## Product owner cannot start a question
    if product.owner.id == current_user.id
      return false
    end

    question = product.questions.new(user_id: current_user.id, addressee_id: product.owner.id, content: values[:content], state: 'active')
    if question.valid?
      question.save
    else
      question.errors.full_messages
    end
  rescue ActiveRecord::RecordNotFound
    ['Record not found']
  end
end
