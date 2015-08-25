class AssignTeamOverlay < CardOverlay

  def self.visit(assign_team_task, &blk)
    page.visit "/papers/#{assign_team_task.paper.id}/tasks/#{assign_team_task.id}"
    wait_for_ajax

    new.tap do |overlay|
      if block_given?
        blk.call overlay
        overlay.dismiss
      end
    end
  end

  def self.navigate_assign_ui(role_name, user_name)
    new.tap do |overlay|
      overlay.select2 role_name, from: "Role"
      wait_for_ajax

      overlay.select2 user_name, from: "User"
      wait_for_ajax

      overlay.click_button "Assign"
    end
  end

end
