class MatchToggleStateRequest
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

  # TODO: change Match.find_by(id: id) to current_user.matches. (security breach?)
  def perform
    id = parameters[:id]
    result = Match.find_by(id: id)
    ## buyer can accept or decline the initial offer
    return false unless result.present?

    state = parameters[:state]
    if state == 'accept' || state == 'decline'
      return false unless current_user.id == result.user_id
    end

    if state == 'confirm'
      return false unless result.products_tradeable?
      return false unless current_user.id == result.buyer_id
    end

    if state == 'withdraw'
      ## can tear down the like - retire the offer
      return false unless current_user.id == result.buyer_id
    end

    buyer_product_id = parameters[:buyer_product_id]
    result&.send("#{state}!", buyer_product_id)
  end
end
