module StandardTasks
  class FiguresController < ::ApplicationController
    rescue_from ActiveRecord::RecordNotFound, with: :render_404

    before_action :authenticate_user!

    def create
      figures = Array.wrap(figure_params.delete(:attachment))

      figures.select! {|f| StandardTasks::Figure.acceptable_content_type? f.content_type }

      if task.present?
        new_figures = figures.map do |figure|
          task.figures.create!(figure_params.merge(attachment: figure))
        end
        respond_to do |f|
          f.json { render json: new_figures }
        end
      else
        head :forbidden
      end
    end

    def update
      figure = StandardTasks::Figure.find params[:id]
      figure.update_attributes figure_params
      respond_to do |f|
        f.json { render json: figure }
      end
    end

    def destroy
      StandardTasks::Figure.find(params[:id]).destroy
      head :ok
    end

    private

    def paper_policy
      @paper_policy ||= PaperPolicy.new(figure_paper.id, current_user)
    end

    def figure_paper
      StandardTasks::FigureTask.find(params[:task_id]).paper
    end

    def figure_params
      params.require(:figure).permit(:title, :caption, :attachment, attachment: [])
    end

    def task
      paper_policy.tasks_for_paper([params[:task_id]]).first
    end

    def render_404
      return head 404
    end
  end
end
