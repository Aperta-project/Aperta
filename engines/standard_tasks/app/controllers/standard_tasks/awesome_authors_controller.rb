module StandardTasks
  class AwesomeAuthorsController < ::ApplicationController
    respond_to :json

    def create
      author = AwesomeAuthor.create(author_params.merge(author_group_id: default_author_group.id))
      respond_with author
    end

    def update
      author = AwesomeAuthor.find(params[:id])
      author.update(author_params)
      respond_with author
    end

    def destroy
      author = AwesomeAuthor.find(params[:id])
      author.destroy if author.present?
      respond_with author
    end

    private

    def author_params
      params.require(:awesome_author).permit(
        :awesome_authors_task_id,
        :first_name,
        :last_name,
        :awesome_name
      )
    end

    def default_author_group
      Task.find(author_params[:awesome_authors_task_id]).paper.author_groups.first
    end
  end
end
