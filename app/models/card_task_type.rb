# CardTaskType contains metadata about the type of Task that should
# be instantiated for a given card when a task is created by the TaskFactory.
# Users can assign a CardType to a Card when creating a new Card in the
# admin screen.
class CardTaskType < ActiveRecord::Base
  validates :display_name, presence: true
  validates :task_class, presence: true

  # maps display_name to task_class
  DEFAULT_NAMES = {
    'CustomCardTask' => 'Custom Card',
    'TahiStandardTasks::UploadManuscriptTask' => 'Upload Manuscript'
  }.freeze

  def self.default_attributes(klass)
    { display_name: DEFAULT_NAMES.fetch(klass), task_class: klass }
  end

  def self.find_or_create_default(klass = 'CustomCardTask')
    find_by(task_class: klass) || create!(default_attributes(klass))
  end

  def self.seed_defaults
    [
      default_attributes('CustomCardTask'),
      default_attributes('TahiStandardTasks::UploadManuscriptTask')
    ].each do |hash|
      CardTaskType.find_or_create_by!(hash)
    end
  end
end
