class Admin::SwipesController < ApplicationController
  def index
    @swipes = Swipe.all.paginate(page: params[:page] || 1, per_page: Vars::PER_PAGE)
  end
end
