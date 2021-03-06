# frozen_string_literal: true

class ApplicationController < ActionController::Base
  NotAuthorized = Class.new(StandardError) # https://stackoverflow.com/questions/25892194/does-rails-come-with-a-not-authorized-exception

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # before_action :appsignal_tagging
  # before_action :store_user_location, if: :storable_location?

  helper_method :current_page_match?

  rescue_from ApplicationController::NotAuthorized do
    redirect_to root_path, alert: "Vous n'avez pas l'autorisation d'accéder à cette page."
  end

  protected

    def bootstrap_table_collection(collection, collection_name)
      collection = filter(collection, params)
      instance_variable_set("@#{collection_name}_count", collection.count)
      offset_and_limit_collection(collection)
    end

    def collection_by_order(collection, sort, order)
      case sort
      when 'transactions_count' then collection.order_by_transactions_count(order)
      else
        collection.reorder(sort.to_sym => order.to_sym)
      end
    end

    def filter(collection, params)
      collection = collection.search_by_name(params[:search]) if params[:search].present?
      if params[:sort].present? && params[:order].present?
        collection_by_order(collection, params[:sort], params[:order])
      else
        collection
      end
    end

    def offset_and_limit_collection(collection)
      collection = collection.offset(params[:offset]) if params[:offset].present?
      collection.limit(params[:limit] || 10)
    end

    def set_organization
      @organization = Organization.find(params[:organization_id]) if params[:organization_id]
    end

  private

    def after_sign_up_or_in_path_for(_user)
      stored_location_for(:user).presence || root_path
    end

    def appsignal_tagging
      Appsignal.tag_request(
        user: current_user&.to_param,
        organization: current_user&.organization&.to_param,
        admin: current_admin&.to_param
      )
    end

    # Ex: current_page_match?(controller: :payments, action: %i[new show]). @dinatih
    def current_page_match?(controller: nil, action: nil)
      [[controller_path, controller], [action_name, action]].all? do |name, option|
        if option.present?
          option.is_a?(Array) ? option.map(&:to_s).include?(name) : name == option.to_s
        else
          true
        end
      end
    end

    def storable_location?
      request.get? && is_navigational_format? && !devise_controller? && !request.xhr? && action_name != 'authenticate'
    end

    def store_user_location
      store_location_for(:user, request.fullpath)
    end
end
