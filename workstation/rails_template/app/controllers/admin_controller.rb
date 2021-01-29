class AdminController < ApplicationController
  def show; end

  def search
    @search_results = PgSearch.multisearch(params[:admin_search_term]).includes(:searchable)
  end
end
