module ClientRouteHelper

  def client_dashboard_url(*args)
    root_url(*args)
  end

  def client_paper_task_url(paper, task)
    "#{root_url}papers/#{paper.to_param}/tasks/#{task.to_param}"
  end

  def client_paper_url(paper, params={})
    if params.present?
      query = "?#{params.to_query}"
    end

    "#{root_url}papers/#{paper.to_param}/#{query}"
  end

end
