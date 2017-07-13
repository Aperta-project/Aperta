Dir[Rails.root.join("lib/custom_card/**/*.rb")].each { |f| require f }

module CustomCard
  class Loader
    def self.all
      Journal.find_each do |journal|
        card_configuration_klasses.each do |card_configuration_klass|
          self.load(card_configuration_klass, journal: journal)
        end
      end
    end

    def self.load(configuration, journal:)
      CustomCard::Factory.new(journal: journal).create(configuration)
    end

    private

    # array of all custom card configuration classes
    #  [CustomCard::Configurations::CompetingInterests, CustomCard::Configurations::CoverLetter ...]
    def self.card_configuration_klasses
      @card_configuration_klasses ||= begin
        CustomCard::Configurations.constants.map(&CustomCard::Configurations.method(:const_get)).grep(Class)
      end
    end
  end
end
