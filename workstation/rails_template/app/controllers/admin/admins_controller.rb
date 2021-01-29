class Admin::AdminsController < AdminController
  before_action :set_admin, only: %i[show edit update]

  def index
    @admins = Admin.all
    @admins = @admins.where(status: params[:filters][:status]) if params[:filters].present?
    @admins_count = @admins.count
    @admins = filter(@admins, params)
    @admins = offset_and_limit_collection(@admins)
  end

  def new
    @admin = Admin.new
  end

  def show; end

  def edit; end

  def create
    @admin = Admin.new(admin_params)

    respond_to do |format|
      if @admin.save
        format.html { redirect_to [:admin, @admin], notice: t('.flashes.notice') }
        format.json { render :show, status: :created, location: @admin }
      else
        format.html { render :new }
        format.json { render json: @admin.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @admin.update(admin_params)
        format.html { redirect_to [:admin, @admin], notice: t('.flashes.notice') }
        format.json { render :show, status: :ok, location: @admin }
      else
        format.html { render :show }
        format.json { render json: @admin.errors, status: :unprocessable_entity }
      end
    end
  end

  def table_columns
    render json: [
      { field: 'id', sortable: true, title: Admin.human_attribute_name(:id) },
      { field: 'email', sortable: true, title: Admin.human_attribute_name(:email) }
    ].to_json
  end

  private

    def set_admin
      @admin = Admin.find(params[:id])
    end

    def admin_params
      if params[:admin][:password].empty?
        params.fetch(:admin, {}).except(:password, :password_confirmation).permit!
      else
        params.fetch(:admin, {}).permit!
      end
    end
end
