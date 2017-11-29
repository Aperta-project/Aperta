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

  def client_discussion_url(discussion, paper, params = {})
    query = "?#{params.to_query}" if params.present?

    "#{root_url}papers/#{paper.to_param}/discussions/" \
      "#{discussion.to_param}/#{query}"
  end

  def client_show_invitation_url(token:)
    "#{root_url}invitations/#{token}"
  end

  def client_show_correspondence_url(correspondence)
    paper = correspondence.paper
    "/papers/#{paper.short_doi}/correspondence/viewcorrespondence/#{correspondence.id}"
  end
end
