# rubocop:disable Metrics/BlockLength
namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-11299: Competing Interests custom card html tag migration fix

      The current Competing Interests card has html tag errors in the <text> element tags of the parsed XML. This
      patches that in the CardContent records that were created.
    DESC

    task aperta_11299_data_migration_competing_interest_card_html_tags: :environment do
      DataTransformation::FixXmlTextNodeValues.new.call
    end
  end
end
