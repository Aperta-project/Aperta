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

end
