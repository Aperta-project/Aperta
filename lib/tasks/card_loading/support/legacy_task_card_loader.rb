require_relative "./card_factory"

# This class is responsible for creating new Cards from Tasks that existed
# prior to the card configuration work ("legacy tasks").
#
# With the card configuration work it will soon become the case that every type
# of Task (i.e., BillingTask) will have an associated Card in the system.  This
# service class will find every kind of Task (excluding CustomCardTask) and
# create a Card for it.
#
# It will not associate any Task instances with this Card since that is outside
# the responsibility of this service class.  That is being handled in a
# separate data migration rake task.
#
# This will not create Cards for non-tasks that are Answerable and associated to
# a CardVersion (Author, GroupAuthor, ReviewerReport, Funder, ReviewerRecommendation)
# since it is presumed that these models already have an existing Card.
#
class LegacyTaskCardLoader
  attr_accessor :tasks

  def initialize(tasks: nil)
    @tasks = tasks || default_legacy_task_klasses
  end

  def load
    # purposely NOT being associated to a Journal since
    # they are cards that are available for ANY Journal to use
    # and therefore not associated with any specific journal
    CardFactory.new(journal: nil).create(card_configuration_klasses)
  end

  private

  def default_legacy_task_klasses
    (::Task.descendants - [CustomCardTask]).reject do |task_klass|
      Card.exists?(name: task_klass)
    end
  end

  # emulates the configuration class format found in
  # lib/tasks/card_loading/configuration/*.rb
  def card_configuration_klasses
    tasks.map do |task|
      OpenStruct.new(name: task.name, content: [])
    end
  end
end
