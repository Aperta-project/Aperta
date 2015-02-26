require_dependency "billing_card/application_controller"

module BillingCard
  class BillingDetailsController < ApplicationController
    before_action :set_billing_detail, only: [:show, :edit, :update, :destroy]

    # GET /billing_details
    def index
      @billing_details = BillingDetail.all
      render json: { billing_details: @billing_details }
    end

    # GET /billing_details/1
    def show
      render json: { billing_detail: @billing_detail }
    end

    # GET /billing_details/new
    def new
      @billing_detail = BillingDetail.new
      render json: { billing_detail: @billing_detail }
    end

    # GET /billing_details/1/edit
    def edit
    end

    # POST /billing_details
    def create
      @billing_detail = BillingDetail.new(billing_detail_params)

      if @billing_detail.save
        # redirect_to @billing_detail, notice: 'Billing detail was successfully created.'
        render json: { billing_detail: @billing_detail }
      else
        render json: { errors: @billing_detail.errors }
        # render :new
      end
    end

    # PATCH/PUT /billing_details/1
    def update
      if @billing_detail.update(billing_detail_params)
        # redirect_to @billing_detail, notice: 'Billing detail was successfully updated.'
        render json: { billing_detail: @billing_detail }
      else
        render json: { errors: @billing_detail.errors }
      end
    end

    # DELETE /billing_details/1
    def destroy
      @billing_detail.destroy
      # redirect_to billing_details_url, notice: 'Billing detail was successfully destroyed.'
      render json: { billing_detail: @billing_detail }
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_billing_detail
        # @billing_detail = BillingDetail.find(params[:id])
        @billing_detail = Task.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def billing_detail_params
        params.require(:billing_detail).permit(
          :address1,
          :address2,
          :affiliation1,
          :affiliation2,
          # :card_thumbnail_id,
          :city,
          # :completed,
          :country,
          :department,
          :email_address,
          :first_name,
          :journal_id,
          :last_name,
          # :lite_paper_id,
          :paper_id,
          # :paper_title,
          :pfa_additional_comments,
          :pfa_amount_to_pay,
          :pfa_funding_statement,
          :pfa_question_1,
          :pfa_question_1a,
          :pfa_question_1b,
          :pfa_question_2,
          :pfa_question_2a,
          :pfa_question_2b,
          :pfa_question_3,
          :pfa_question_3a,
          :pfa_question_4,
          :pfa_question_4a,
          :pfa_supporting_docs,
          # :phase_id,
          :phone_number,
          :postal_code,
          # :qualified_type,
          # :role,
          :state,
          :title,
          :payment_method,
          :author_confirmation
          # :type
        )
      end
  end
end
