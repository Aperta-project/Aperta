require_relative "./card_factory"
Dir[Rails.root.join("lib/tasks/card_loading/configurations/*.rb")].each { |f| require f }
Dir[Rails.root.join("lib/tasks/card_loading/configurations/nonstandard_configurations/*")].each { |f| require f }

# This class is responsible for looking up one or more CardConfiguration
# classes and sending it to the CardFactory so that new Cards can be created in
# the system with the correct attributes.
#
class CardLoader
  def self.load_standard(journal: nil)
    CardFactory.new(journal: journal).create(standard_card_configuration_klasses)
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

  # array of all normal card configuration classes
  #  [CardConfiguration::Author, CardConfiguration::AuthorsTask ...]
  def self.standard_card_configuration_klasses
    @standard_configurations ||= begin
      CardConfiguration.constants.map(&CardConfiguration.method(:const_get)).grep(Class)
    end
  end

  # array of all card configuration classes we don't want on production
  def self.nonstandard_card_configuration_klasses
    @nonstandard_configurations ||= begin
      mmodule = CardConfiguration::NonstandardConfigurations
      mmodule.constants.map(&mmodule.method(:const_get)).grep(Class)
    end
  end

  def self.card_configuration_klasses
    standard_card_configuration_klasses + nonstandard_card_configuration_klasses
  end
end
