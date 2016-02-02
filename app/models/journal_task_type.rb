class JournalTaskType < ActiveRecord::Base
  belongs_to :journal, inverse_of: :journal_task_types
  validates :old_role, :title, presence: true
  after_create :log_created_record

  def required_permissions
    permissions_data = read_attribute(:required_permissions)
    return [] if permissions_data.blank?

    query = nil
    permissions_data.each_with_index do |hsh, i|
      if i == 0
        query = Permission.arel_table[:action].eq(hsh['action'])
          .and(Permission.arel_table[:applies_to].eq(hsh['applies_to']))
      else
        query = query.or(
          Permission.arel_table[:action].eq(hsh['action'])
          .and(Permission.arel_table[:applies_to].eq(hsh['applies_to']))
          )
      end
    end

    Permission.where(query)
  end

  private

  def log_created_record
    Rails.logger.info "Created #{kind} JournalTaskType"
  end
end
