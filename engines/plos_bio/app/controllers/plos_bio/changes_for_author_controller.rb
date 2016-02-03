require_dependency "plos_bio/application_controller"

module PlosBio
  class ChangesForAuthorController < ApplicationController
    before_action :authenticate_user!

    def send_email
      task = Task.find(params[:id])
      task.notify_changes_for_author
      render json: { success: true }
    end

    def submit_tech_check
      task = Task.find(params[:id])
      paper = task.paper

      if paper.submit_minor_check! current_user
        increment_initial_tech_check_round! paper
        task.notify_tech_fixed
        notify_paper_tech_fixed!(paper)
        render json: paper
      else
        render json: paper, status: 422
      end
    end

    private

    def notify_paper_tech_fixed! paper
      Activity.create(
        feed_name: 'manuscript',
        activity_key: 'paper.tech_fixed',
        subject: paper,
        user: current_user,
        message: 'Author tech fixes were submitted'
      )
    end

    def increment_initial_tech_check_round! paper
      itc_task = paper.tasks.detect { |task| task.is_a? InitialTechCheckTask }
      itc_task.increment_round! if itc_task
    end
  end
end
