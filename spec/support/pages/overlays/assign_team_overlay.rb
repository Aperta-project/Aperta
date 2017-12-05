class AssignTeamOverlay < CardOverlay
  def self.visit(assign_team_task, &blk)
    page.visit "/papers/#{assign_team_task.paper.id}/tasks/#{assign_team_task.id}"

    new.tap do |overlay|
      if block_given?
        page.assert_selector(".overlay-container .overlay-body")
        blk.call overlay
        overlay.dismiss
      end
    end
  end

  def assign_role_to_user(role_name, user)
    page.assert_selector(".assign-team-content")

    select2 role_name, from: "Role"

    select2 user.full_name, css: '.assignment-user-input', search: true

    click_button "Assign"
  end

  def unassign_user(user)
    trash_icon = find(".invitation", text: user.full_name).find(".invite-remove")
    trash_icon.click
  end
end
