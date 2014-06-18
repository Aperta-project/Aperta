module FinancialDisclosure
  class FundersController < ::ApplicationController
    respond_to :json

    def create
      funder = Funder.create(funder_params)
      respond_with funder
    end

    def update
      funder = Funder.find(params[:id])
      funder.update_attributes(funder_params)
      respond_with funder
    end

    def destroy
      funder = Funder.find(params[:id])
      funder.destroy
      respond_with funder
    end

    private

    def funder_params
      params.require(:funder).permit(:name, :grant_number, :website, :funder_had_influence, :funder_influence_description, :task_id, author_ids: [])
    end
  end
end
