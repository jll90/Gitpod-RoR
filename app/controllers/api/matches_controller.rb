class Api::MatchesController < BaseApiController
  before_action :authenticate_request
  before_action :verify_state_parameter, only: :update_state
  before_action :set_match, only: [:show, :unlock]
  before_action :verify_match_ownership, only: [:show, :unlock]

  def can_pay_matches
    states = %i[accepted confirmed withdrawn disqualified]
    matches = Match.where(user_id: current_user.id).or(Match.where(buyer_id: current_user.id)).where(state: states).order("updated_at DESC")
    render_matches(matches, [buyer: { only: User.social_fields }, user: { only: User.social_fields }])
  end

  def show 
    opts = { include: [user: { only: User.social_fields }, buyer: { only: User.social_fields }], methods: %i[products] }
    render_match(opts)
  end

  def unlock
    return head :bad_request unless @match.state == 'confirmed'
    opts = { include: [user: { only: User.contact_fields }, buyer: { only: User.contact_fields, methods: %[avatar_attachment] }], methods: %i[products] }
    render_match opts
  end

  def render_match(opts)
    json_success({ record: @match }, 200, opts)
  end

  def user_matches
    ## received_likes
    render_matches(current_user.matches.send(params[:state]).order("id DESC"), [buyer: { only: User.social_fields }])
  end

  def user_requested_matches
    ## sent_likes
    render_matches(current_user.buyer_matches.send(params[:state]).order("id DESC"))
  end

  def update_state
    success = MatchToggleStateRequest.call(current_user, params).result
    if success
      json_success
    else
      head :bad_request
    end
  rescue AASM::InvalidTransition
    head :no_content
  end

  def mark_as_read
    success = MatchMarkAsReadRequest.call(current_user, params).result
    success ? json_success : head(:bad_request)
  end

  private

  def set_match
    @match = Match.find_by(id: params[:id])
    return head :not_found unless @match.present?
  end

  def verify_match_ownership
    return head :forbidden unless @match.owned_by? current_user
  end

  def render_matches(records, inklude = [])
    render json: RecordsPagination.call(records, params[:page] || 1, params[:per_page] || 100, { methods: %i[products], include: inklude }).result
  end

  def verify_state_parameter
    return json_error('state field must be present') if params[:state].nil?

    match_states = request.method == 'PATCH' ? Match::VALID_TRANSITIONS : Match::VALID_STATES
    return json_error('invalid state') if match_states.exclude?(params[:state].to_sym)
  end
end
