# frozen_string_literal: true

class PayoutsController < ApplicationController
  before_action :set_payout, only: %i[show edit update destroy]
  before_action :set_organization

  # GET /payouts or /payouts.json
  def index
    @payouts = Payout.all
    @payouts = @organization.payouts if @organization
    @payouts = bootstrap_table_collection(@payouts, :payouts)
  end

  # GET /payouts/1 or /payouts/1.json
  def show; end

  # GET /payouts/new
  def new
    @payout = Payout.new
  end

  # GET /payouts/1/edit
  def edit; end

  # POST /payouts or /payouts.json
  def create
    @payout = Payout.new(payout_params)

    respond_to do |format|
      if @payout.save
        format.html { redirect_to @payout, notice: 'Payout was successfully created.' }
        format.json { render :show, status: :created, location: @payout }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @payout.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /payouts/1 or /payouts/1.json
  def update
    respond_to do |format|
      if @payout.update(payout_params)
        format.html { redirect_to @payout, notice: 'Payout was successfully updated.' }
        format.json { render :show, status: :ok, location: @payout }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @payout.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payouts/1 or /payouts/1.json
  def destroy
    @payout.destroy
    respond_to do |format|
      format.html { redirect_to payouts_url, notice: 'Payout was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def table_columns
    render json: [
      { field: 'amount', sortable: true, title: Payout.human_attribute_name(:amount) },
      { field: 'succeeded_at', sortable: true, title: Payout.human_attribute_name(:succeeded_at) },
      { field: 'article', title: Payout.human_attribute_name(:article) }
    ].to_json
  end

  private

    def set_organization
      @organization = Organization.find(params[:organization_id]) if params[:organization_id]
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_payout
      @payout = Payout.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def payout_params
      params.require(:payout).permit(:organization_id, :article_id, :user_id, :amount, :succeeded_at)
    end
end
