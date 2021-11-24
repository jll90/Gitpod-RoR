class Admin::MatchesController < ApplicationController
  def index
    case params[:state]
    when 'pending'
      @matches = Match.pending.paginate(page: params[:page] || 1, per_page: Vars::PER_PAGE)
      @title = 'Matchs pendientes'
    when 'finished'
      @matches = Match.finished.paginate(page: params[:page] || 1, per_page: Vars::PER_PAGE)
      @title = 'Matchs pagados'
    when 'declined'
      @matches = Match.declined.paginate(page: params[:page] || 1, per_page: Vars::PER_PAGE)
      @title = 'Matchs rechazados'
    else
      @matches = Match.all.paginate(page: params[:page] || 1, per_page: Vars::PER_PAGE)
      @title = 'Todos los Matchs'
    end
  end
end
