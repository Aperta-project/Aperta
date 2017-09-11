# CardTaskType contains metadata about the type of Task that should
# be instantiated for a given card when a task is created by the TaskFactory.
# Users can assign a CardType to a Card when creating a new Card in the
# admin screen.
class CardTaskType < ActiveRecord::Base
  validates :display_name, presence: true
  validates :task_class, presence: true

  def self.seed_defaults
    [
      { display_name: 'Custom Card', task_class: 'CustomCardTask' },
      { display_name: 'Upload Manuscript', task_class: 'TahiStandardTasks::UploadManuscriptTask' }
    ].each do |hash|
      CardTaskType.find_or_create_by(hash)
    end
  end
end
