class Admin::HomeController < ApplicationController
  def index
    swipe_records = Swipe.group(:liked).count
    @swipe_pie = {
      Like: swipe_records[true],
      Dislike: swipe_records[false]
    }
    @users_line = User.group_by_day(:created_at).count
  end
end
