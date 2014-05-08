class ManuscriptManagerTemplate < ActiveRecord::Base
  belongs_to :journal

  validates :paper_type, presence: true
  validates :paper_type, uniqueness: { scope: :journal_id }

  validate :no_duplicate_phase_names
  validate :task_types_in_whitelist

  def phases
    template["phases"] || []
  end

  private

  def task_types
    phases.flat_map { |phase| phase["task_types"] }.compact.uniq
  end

  def no_duplicate_phase_names
    names = phases.map { |phase| phase["name"] }
    unless names.length == names.uniq.length
      errors.add(:phases, "Phases cannot have duplicate names.")
    end
  end

  def task_types_in_whitelist
    if task_types.present? && task_types.any? { |task_type| !Journal::VALID_TASK_TYPES.include? task_type }
      errors.add(:task_types, "Task types must be in the allowed list.")
    end
  end

end
