module FeatureHelpers
  def ensure_user_does_not_have_access_to_task(user:, task:)
    logout
    expect(user).to be

    login_as(user, scope: :user)
    visit '/'
    Page.view_paper paper
    expect(page).to have_no_css('.task-disclosure', text: task.title)

    Page.view_task task
    expect(page).to have_content("You don't have access to that content")
  end
end
