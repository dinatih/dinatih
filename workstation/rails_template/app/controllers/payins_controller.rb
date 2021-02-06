# frozen_string_literal: true

class PayinsController < ApplicationController
  before_action :set_payin, only: %i[show edit update destroy]
  before_action :set_organization

  # GET /payins or /payins.json
  def index
    @payins = Payin.all
    @payins = @organization.payins if @organization
    @payins = bootstrap_table_collection(@payins, :payins)
  end

  # GET /payins/1 or /payins/1.json
  def show; end

  # GET /payins/new
  def new
    @payin = Payin.new
  end

  # GET /payins/1/edit
  def edit; end

  # POST /payins or /payins.json
  def create
    @payin = Payin.new(payin_params)

    respond_to do |format|
      if @payin.save
        format.html { redirect_to @payin, notice: 'Payin was successfully created.' }
        format.json { render :show, status: :created, location: @payin }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @payin.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /payins/1 or /payins/1.json
  def update
    respond_to do |format|
      if @payin.update(payin_params)
        format.html { redirect_to @payin, notice: 'Payin was successfully updated.' }
        format.json { render :show, status: :ok, location: @payin }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @payin.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payins/1 or /payins/1.json
  def destroy
    @payin.destroy
    respond_to do |format|
      format.html { redirect_to payins_url, notice: 'Payin was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def table_columns
    render json: [
      { field: 'amount', sortable: true, title: Payin.human_attribute_name(:amount) },
      { field: 'succeeded_at', sortable: true, title: Payin.human_attribute_name(:succeeded_at) },
      { field: 'product', title: Payin.human_attribute_name(:product) }
    ].to_json
  end

  private

    def set_organization
      @organization = Organization.find(params[:organization_id]) if params[:organization_id]
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_payin
      @payin = Payin.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def payin_params
      params.require(:payin).permit(:organization_id, :product_id, :user_id, :amount, :succeeded_at)
    end
end
