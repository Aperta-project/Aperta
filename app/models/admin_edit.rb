# Record of an admin editing someone else's content, e.g., reviewer reports
class AdminEdit < ActiveRecord::Base
  include ViewableModel
  belongs_to :reviewer_report
  belongs_to :user

  scope :active, -> { where(active: true) }
  scope :completed, -> { where(active: false) }

  def user_can_view?(user)
    user.can?(:edit_answers, reviewer_report.paper)
  end

  def self.edit_for(report)
    first_active = report.admin_edits.active.first
    if first_active.present?
      first_active
    else
      report.answers.each do |answer|
        additional = answer.additional_data || {}
        additional[:pending_edit] = answer.value
        answer.update(additional_data: additional)
      end
      report.admin_edits.create(reviewer_report: report, active: true)
    end
  end
end
