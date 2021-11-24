class Admin::UsersController < ApplicationController
  def index
    @users = User.all.paginate(page: params[:page] || 1, per_page: Vars::PER_PAGE)
  end

  def show
    @user = User.find(params[:id])
    @products = @user.products.paginate(page: params[:page] || 1, per_page: Vars::PER_PAGE)
  end
end
