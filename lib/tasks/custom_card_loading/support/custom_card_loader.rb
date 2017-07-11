Dir[Rails.root.join("lib/tasks/custom_card_loading/support/*.rb")].each { |f| require f }
Dir[Rails.root.join("lib/tasks/custom_card_loading/configurations/*.rb")].each { |f| require f }

class CustomCardLoader
  def self.load_all(journal: nil)
    Array(journal || Journal.all).each do |journal|
      card_configuration_klasses.map do |card_configuration_klass|
        load(card_configuration_klass, journal: journal)
      end
    end
  end

  def self.load(card_configuration_klass, journal:)
    CustomCardFactory.new(journal: journal).create(card_configuration_klass)
  end

  private

  # array of all custom card configuration classes
  #  [CustomCardConfiguration::CompetingInterests, CustomCardConfiguration::CoverLetter ...]
  def self.card_configuration_klasses
    @card_configuration_klasses ||= begin
      CustomCardConfiguration.constants.map(&CustomCardConfiguration.method(:const_get)).grep(Class)
    end
  end
end
