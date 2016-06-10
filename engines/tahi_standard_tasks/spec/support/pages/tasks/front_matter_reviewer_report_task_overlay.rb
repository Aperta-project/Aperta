# encoding: utf-8
require File.dirname(__FILE__) + '/reviewer_report_task_overlay'

class FrontMatterReviewerReportTaskOverlay < ReviewerReportTaskOverlay
  def fill_in_report(values={})
    values = values.with_indifferent_access.reverse_merge(
      "front_matter_reviewer_report--competing_interests" => "default competing interests content",
      "front_matter_reviewer_report--additional_comments" => "default additional_comments content",
      "front_matter_reviewer_report--identity" => "default identity content"
    )

    values.each_pair do |key, value|
      element_name = "#{key}"
      fill_in element_name, with: value
      page.execute_script "$('*[name=\\'#{element_name}\\']').trigger('change')"
    end
  end

  def reload(reviewer_report_task=TahiStandardTasks::FrontMatterReviewerReportTask.last)
    paper = reviewer_report_task.paper
    visit "/papers/#{paper.id}/tasks/#{reviewer_report_task.id}"
  end
end
