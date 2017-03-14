require_relative "./card_factory"
Dir[Rails.root.join("lib/tasks/card_loading/configurations/*")].each { |f| require f }

# This class is responsible for looking up one or more CardConfiguration
# classes and sending it to the CardFactory so that new Cards can be created in
# the system with the correct attributes.
#
class CardLoader
  def self.load_all(journal: nil)
    CardFactory.new(journal: journal).create(card_configuration_klasses)
    count = CardContent.where.not(ident: nil).count
    nq_count = NestedQuestion.count
    $stderr.puts("Created #{count} CardContent questions (c.f. #{nq_count} nested questions)")
    unless Rails.env.test?
      raise 'Expected to create a new CardContent for every NestedQuestion' unless count == nq_count
    end
  end

  def self.load(owner_klass, journal: nil)
    CardFactory.new(journal: journal).create(find_configuration_klass(owner_klass))
  end

  # find particular card configuration klass by examining it's name
  def self.find_configuration_klass(name)
    configuration_klass = card_configuration_klasses.find { |klass| klass.name == name }
    raise "Cannot find card configuration class for #{name}" unless configuration_klass
    configuration_klass
  end

  # array of all card configuration classes
  #  [CardConfiguration::Author, CardConfiguration::AuthorsTask ...]
  def self.card_configuration_klasses
    @configurations ||= begin
      CardConfiguration.constants.map(&CardConfiguration.method(:const_get)).grep(Class)
    end
  end
end
