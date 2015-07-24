module ClientRouteHelper

  def client_dashboard_url
    root_url
  end

  def client_paper_task_url(paper, task)
    "#{root_url}papers/#{paper.to_param}/tasks/#{task.to_param}"
  end

  def client_paper_url(paper, params = {})
    if params.empty?
      "#{root_url}papers/#{paper.to_param}"
    else
      "#{root_url}users/sign_up?#{params.to_query}"
    end
  end

  def client_edit_paper_url(paper)
    "#{root_url}papers/#{paper.to_param}/edit"
  end

end
