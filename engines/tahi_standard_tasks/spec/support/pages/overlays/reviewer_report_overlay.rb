class ReviewerReportOverlay < CardOverlay
  def fill_in_report(values={})
    values = values.with_indifferent_access.reverse_merge(
      "competing_interests" => "default competing interests content",
      "support_conclusions.explanation" => "default support_conclusions.explanation content",
      "statistical_analysis.explanation" => "default statistical_analysis.explanation content",
      "standards.explanation" => "default standards.explanation content",
      "intelligible.explanation" => "default intelligible.explanation content",
      "additional_comments" => "default additional_comments content",
      "identity" => "default identity content"
    )

    values.each_pair do |key, value|
      element_name = "reviewer_report.#{key}"
      fill_in element_name, with: value
      page.execute_script "$('*[name=\\'#{element_name}\\']').trigger('change')"
    end
    wait_for_ajax
  end

  def submit_report
    click_button "Submit this Report"
  end

  def confirm_submit_report
    click_button "Yes, I’m sure"
  end

  def reload(reviewer_report_task=TahiStandardTasks::ReviewerReportTask.last)
    paper = reviewer_report_task.paper
    visit "/papers/#{paper.id}/tasks/#{reviewer_report_task.id}"
  end
end
