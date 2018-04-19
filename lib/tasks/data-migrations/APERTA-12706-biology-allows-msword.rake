# rubocop:disable Metrics/BlockLength
namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-12706: PLOS Biology allows msword manuscripts
    DESC

    task aperta_12706_biology_allows_msword: :environment do
      journal = Journal.find_by(name: "PLOS Biology")
      return unless journal

      # rubocop:disable Rails/SkipsModelValidations
      journal.update_column(:msword_allowed, true)
      # rubocop:enable Rails/SkipsModelValidations
      raise unless Journal.find_by(name: "PLOS Biology").reload.msword_allowed?
    end
  end
end
