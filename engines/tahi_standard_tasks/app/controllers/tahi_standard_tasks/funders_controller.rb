module TahiStandardTasks
  class FundersController < ::ApplicationController
    before_action :authenticate_user!

    respond_to :json

    def create
      task = Task.find(funder_params[:task_id])
      funder = task.funders.new(funder_params)
      authorize_action!(funder: funder)
      funder.save
      respond_with funder
    end

    def update
      funder = Funder.find(params[:id])
      authorize_action!(funder: funder)
      unmunge_empty_arrays!(:funder, [:author_ids])
      funder.update_attributes(funder_params)
      respond_with funder
    end

    def destroy
      funder = Funder.find(params[:id])
      authorize_action!(funder: funder)
      funder.destroy
      respond_with funder
    end

    private

    def funder_params
      params.require(:funder)
      .permit(:name,
              :grant_number,
              :website,
              :funder_had_influence,
              :funder_influence_description,
              :task_id,
              author_ids: [])
    end
  end
end
