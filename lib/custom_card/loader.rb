Dir[Rails.root.join("lib/custom_card/**/*.rb")].each { |f| require f }

module CustomCard
  # The purpose of this class is to provide a common interface for
  # creating custom Cards for specified Journals.
  #
  # rubocop:disable Metrics/LineLength, Style/RedundantSelf
  class Loader
    def self.all
      Journal.find_each do |journal|
        card_configuration_klasses.each do |card_configuration_klass|
          self.load(card_configuration_klass, journal: journal)
        end
      end
    end

    def self.load!(configuration, journal:)
      self.load(configuration, journal: journal).tap do |cards|
        if cards.compact.empty?
          raise "Card for #{configuration} could not be loaded for journal #{journal.id}"
        end
      end
    end

    def self.load(configuration, journal:)
      CustomCard::Factory.new(journal: journal).first_or_create(configuration)
    end

    private

    # array of all custom card configuration classes
    #  [CustomCard::Configurations::CompetingInterests, CustomCard::Configurations::CoverLetter ...]
    def self.card_configuration_klasses
      @card_configuration_klasses ||= begin
        CustomCard::Configurations.constants.map(
          &CustomCard::Configurations.method(:const_get)
        ).grep(Class).reject { |klass|
          # do not include base class that is inherited from
          klass == CustomCard::Configurations::Base
        }
      end
    end
  end
  # rubocop:enable Metrics/LineLength, Style/RedundantSelf
end
