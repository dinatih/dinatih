# frozen_string_literal: true

class Admin::UsersController < AdminController
  before_action :set_user, only: %i[show edit update destroy]
  before_action :set_organization

  # GET /admin/users
  # GET /admin/users.json
  def index
    @users = User.includes(:organization).order(id: :desc)
    @users = @organization.users if @organization
    @users_count = @users.count
    @users = filter(@users, params)
    @users = offset_and_limit_collection(@users)
  end

  # GET /admin/users/1
  # GET /admin/users/1.json
  def show
  end

  # GET /admin/users/new
  def new
    @user = User.new
  end

  # GET /admin/users/1/edit
  def edit; end

  # POST /admin/users
  # POST /admin/users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: t('.flashes.notice') }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/users/1
  # PATCH/PUT /admin/users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to [:admin, @user], notice: t('.flashes.notice') }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/users/1
  # DELETE /admin/users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to admin_users_url, notice: t('.flashes.notice') }
      format.json { head :no_content }
    end
  end

  def table_columns
    render json: [
      { field: 'id', sortable: true, title: User.human_attribute_name(:id) },
      { field: 'organization', title: User.human_attribute_name(:organization) },
      { field: 'created_at', sortable: true, title: User.human_attribute_name(:created_at) },
      { field: 'updated_at', sortable: true, title: User.human_attribute_name(:updated_at) }
    ].to_json
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      if params[:user][:password].empty?
        params.fetch(:user, {}).except(:password, :password_confirmation).permit!
      else
        params.fetch(:user, {}).permit!
      end
    end

    def set_organization
      @organization = Organization.find(params[:organization_id]) if params[:organization_id]
    end
end
