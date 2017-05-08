# encoding: utf-8
require File.dirname(__FILE__) + '/reviewer_report_task_overlay'

class FrontMatterReviewerReportTaskOverlay < ReviewerReportTaskOverlay
  include RichTextEditorHelpers

  def fill_in_report(values = {})
    values = values.with_indifferent_access.reverse_merge(
      "front_matter_reviewer_report--competing_interests" => "default competing interests content",
      "front_matter_reviewer_report--additional_comments" => "default additional_comments content",
      "front_matter_reviewer_report--identity" => "default identity content"
    )

    fill_in_fields(values)
  end

  def fill_in_fields(values = {})
    values.each_pair do |key, value|
      fill_in_rich_text editor: key, text: value
    end
  end

  def reload(reviewer_report_task=TahiStandardTasks::FrontMatterReviewerReportTask.last)
    paper = reviewer_report_task.paper
    visit "/papers/#{paper.id}/tasks/#{reviewer_report_task.id}"
  end
end
