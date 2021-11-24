# frozen_string_literal: true

class Api::QuestionsController < BaseApiController
  before_action :authenticate_request, except: [:index_for_product, :show]
  before_action :find_question, only: [:show, :mark_as_read]
  before_action :check_ownership, only: [:mark_as_read]

  def create
    success = ProductCreateQuestionRequest.call(current_user, params).result
    success == true ? json_success({}, 201): json_error(success)
  end

  def show
    ## must work for authenticated and unauthenticated users
    @current_user = AuthorizeApiRequest.call(request.headers).result
    if @current_user
      @question.current_user_id = @current_user.id
      json_success({ record: @question}, 200, json_opts(true, true))
    else
      json_success({ record: @question}, 200, json_opts(true, true))
    end
  end

  def index_for_product
    product_id = params[:product_id]
    questions = Question.includes(:replies, replies: [:reply_receipts]).where(product_id: product_id).order('updated_at DESC')
    render json: RecordsPagination.call(questions, nil, nil, json_opts(true, false)).result
  end

  def index_for_user
    ## questions where I have replied and questions that I have been asked (concat)
    question_ids = Reply.where(user_id: current_user.id).pluck(:question_id) + Question.where(addressee_id: current_user.id).ids
    questions = Question.includes(:product, :replies, replies: [:reply_receipts]).where(id: question_ids.uniq).order('updated_at DESC')
    questions.map { |q| q.current_user_id = current_user.id }
    render json: RecordsPagination.call(questions, nil, nil, json_opts(true, true)).result
  end

  def mark_as_read
    @question.mark_as_read(current_user.id)
    head :no_content
  end

  private

  def json_opts(include_replies = false, include_product = false)
    inkludes = []
    methods = %i[latest_reply reply_count]
    inkludes = inkludes + [:replies, replies: { include: [:reply_receipts] }] if include_replies
    inkludes = inkludes + [:product, product: { methods: %i[attachments] } ] if include_product
    { include: inkludes, methods: methods }
  end

  def find_question
    @question = Question.includes(:replies).find_by(id: params[:id])
    return head :not_found if @question.nil?
  end

  def check_ownership
    return head :forbidden unless @question.is_participant? current_user.id
  end
end
