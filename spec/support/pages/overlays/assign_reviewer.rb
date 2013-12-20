class AssignReviewerOverlay < CardOverlay
  def paper_reviewers=(names)
    names.each do |name|
      select name, from: 'Reviewers'
    end
  end

  def paper_reviewer
    selected_option = all('#task_paper_role_attributes_user_id option[selected]').first
    selected_option.try :text
  end
end
