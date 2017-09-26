# rubocop:disable Metrics/BlockLength
namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-11336: Change the text areas to basic TinyMCE in Ethics cards
    DESC

    task aperta_11336_fix_ethics_statement_text_fields: :environment do
      idents = %w[ethics--human_subjects--participants ethics--animal_subjects--field_permit ethics--field_study--field_permit_number]

      CardContent.transaction do
        idents.each do |ident|
          card_contents = CardContent.where(ident: ident)
          if card_contents.empty?
            p "No matching cards were found for ident: " + ident
          end
          card_contents.each do |content|
            p "Updating: ID: " + content.id.to_s + " IDENT:" + content.ident + " VALUE_TYPE: " + content.value_type
            result = content.update("value_type": "html")
            unless result
              raise Exception "Failed to update Card Content #{content.id}."
            end
          end
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
