class ChangeCorrespondenceSentAt < ActiveRecord::Migration
  def change
    # this should no-op
    # this migration previously added a not-null constraint, but we changed our minds.
    # Editing this migration to no-op as well as adding an additional migration which
    # ensures the constraint is removed was our best attempt at reversing this change
    # without confusing environments which have already run the previous version of this
    # migration. See 20171026232520_remove_not_null_on_email_log_sent_at
    change_column :email_logs, :sent_at, :datetime, null: true
  end
end
