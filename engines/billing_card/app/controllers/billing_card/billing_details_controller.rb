require_dependency "billing_card/application_controller"

module BillingCard
  class BillingDetailsController < ApplicationController
    before_action :set_billing_detail, only: [:show, :edit, :update, :destroy]

    # GET /billing_details
    def index
      @billing_details = BillingDetail.all
    end

    # GET /billing_details/1
    def show
    end

    # GET /billing_details/new
    def new
      @billing_detail = BillingDetail.new
    end

    # GET /billing_details/1/edit
    def edit
    end

    # POST /billing_details
    def create
      @billing_detail = BillingDetail.new(billing_detail_params)

      if @billing_detail.save
        redirect_to @billing_detail, notice: 'Billing detail was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /billing_details/1
    def update
      if @billing_detail.update(billing_detail_params)
        redirect_to @billing_detail, notice: 'Billing detail was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /billing_details/1
    def destroy
      @billing_detail.destroy
      redirect_to billing_details_url, notice: 'Billing detail was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_billing_detail
        @billing_detail = BillingDetail.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def billing_detail_params
        params[:billing_detail]
      end
  end
end
