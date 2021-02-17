# frozen_string_literal: true

class Admin::AdminController < ApplicationController
  def index; end

  def search
    @search_results = PgSearch.multisearch(params[:admin_search_term]).includes(:searchable)
  end
end
