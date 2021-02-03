# frozen_string_literal: true

class PaymentsController < ApplicationController
  before_action :set_payment, only: %i[show edit update destroy]
  before_action :set_organization

  # GET /payments or /payments.json
  def index
    @payments = Payment.all
    @payments = @organization.payments if @organization
    @payments = @payments.where(status: params[:filters][:status]) if params[:filters].present?
    @payments_count = @payments.count
    @payments = filter(@payments, params)
    @payments = offset_and_limit_collection(@payments)
  end

  # GET /payments/1 or /payments/1.json
  def show; end

  # GET /payments/new
  def new
    @payment = Payment.new
  end

  # GET /payments/1/edit
  def edit; end

  # POST /payments or /payments.json
  def create
    @payment = Payment.new(payment_params)

    respond_to do |format|
      if @payment.save
        format.html { redirect_to @payment, notice: 'Payment was successfully created.' }
        format.json { render :show, status: :created, location: @payment }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /payments/1 or /payments/1.json
  def update
    respond_to do |format|
      if @payment.update(payment_params)
        format.html { redirect_to @payment, notice: 'Payment was successfully updated.' }
        format.json { render :show, status: :ok, location: @payment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payments/1 or /payments/1.json
  def destroy
    @payment.destroy
    respond_to do |format|
      format.html { redirect_to payments_url, notice: 'Payment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def table_columns
    render json: [
      { field: 'amount', sortable: true, title: Payment.human_attribute_name(:amount) },
      { field: 'succeeded_at', sortable: true, title: Payment.human_attribute_name(:succeeded_at) },
      { field: 'article', sortable: true, title: Payment.human_attribute_name(:article) }
    ].to_json
  end

  private

    def set_organization
      @organization = Organization.find(params[:organization_id]) if params[:organization_id]
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_payment
      @payment = Payment.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def payment_params
      params.require(:payment).permit(:organization_id, :article_id, :user_id, :amount, :succeeded_at)
    end
end
