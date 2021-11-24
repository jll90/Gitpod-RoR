class MatchMarkAsReadRequest
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
    id = parameters[:id]
    result = current_user.matches.find_by(id: id)
    
    return false if result.nil?

    if current_user.id == result.user_id
      result.update_column(:user_read, true)
    else
      result.update_column(:buyer_read, true)
    end
  end
end
