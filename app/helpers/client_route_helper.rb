module ClientRouteHelper

  def client_dashboard_url
    root_url
  end

  def client_paper_task_url(paper, task)
    "#{root_url}papers/#{paper.to_param}/tasks/#{task.to_param}"
  end

  def client_paper_url(paper)
    "#{root_url}papers/#{paper.to_param}"
  end

end
