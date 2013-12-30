class AssignReviewerOverlay < CardOverlay
  def paper_reviewers=(names)
    names.each do |name|
      select name, from: 'Reviewers'
    end
  end

  def paper_reviewers
    all('#task_paper_roles option[selected]').map(&:text)
  end
end
