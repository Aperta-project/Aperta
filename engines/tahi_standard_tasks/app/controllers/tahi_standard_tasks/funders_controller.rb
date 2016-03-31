module TahiStandardTasks
  class FundersController < ::ApplicationController
    before_action :authenticate_user!

    respond_to :json

    def create
      task = Task.find(funder_params[:task_id])
      requires_user_can :edit, task
      funder = task.funders.new(funder_params)
      funder.save
      respond_with funder
    end

    def update
      funder = Funder.find(params[:id])
      requires_user_can :edit, funder.task
      unmunge_empty_arrays!(:funder, [:author_ids])
      funder.update_attributes(funder_params)
      respond_with funder
    end

    def destroy
      funder = Funder.find(params[:id])
      requires_user_can :edit, funder.task
      funder.destroy
      respond_with funder
    end

    private

    def funder_params
      params.require(:funder)
        .permit(:additional_comments,
                :name,
                :grant_number,
                :website,
                :task_id,
                author_ids: [])
    end
  end
end
