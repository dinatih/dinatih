class Admin::UsersController < AdminController
  before_action :set_user, only: %i[show edit update destroy validate]
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
    @months = []

    if @user.transactions_as_supplier.present?
      @min_date = @user.transactions_as_supplier.minimum(:start_date)
      @max_date = @user.transactions_as_supplier.maximum(:start_date)
      @months = (@min_date..@max_date).map(&:beginning_of_month).uniq
    end

    @user.check_mangopay_mandate_status! if @user.check_mangopay_mandate_status?
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

  def newsletter_subscribers
    @users = User.select(:id, :last_name, :first_name, :email, :created_at, :moderated, :last_sign_in_at, :organization_id)
    respond_to do |format|
      format.csv do
        render plain: @users.to_csv(%i[id last_name first_name email created_at moderated last_sign_in_at articles_count
                                       bookings_count organization_name]), content_type: 'text/plain'
      end
      format.json do
        render json: @users.as_json(methods: %i[last_sign_in_at articles_count bookings_count organization_name])
      end
    end
  end

  def table_columns
    render json: [
      { field: 'id', sortable: true, title: Booking.human_attribute_name(:id) },
      { field: 'last_name', sortable: true, title: Booking.human_attribute_name(:name) },
      { field: 'organization', title: Booking.human_attribute_name(:organization) },
      { field: 'created_at', sortable: true, title: Booking.human_attribute_name(:created_at) },
      { field: 'updated_at', sortable: true, title: Booking.human_attribute_name(:updated_at) },
      { field: 'profile_complete', title: Booking.human_attribute_name(:profile_complete) },
      { field: 'moderated', sortable: true, title: Booking.human_attribute_name(:moderated) }
    ].to_json
  end

  def validate
    @user.toggle(:moderated)
    @user.save!
    redirect_to [:admin, @user]
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
