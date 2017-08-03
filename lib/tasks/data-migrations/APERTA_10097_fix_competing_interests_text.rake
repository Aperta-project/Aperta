namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-10097: Competing Interests custom card text fix

      The original Competing Interests conversion had a text error in XML that was loaded. This
      patches that in the CardContent records that were created.
    DESC

    task aperta_10097_competing_interests_text_fix: :environment do
      card_contents = CardContent.where(ident: 'competing_interests--statement')
      if card_contents.empty?
        raise Exception, "No matching cards were found - has Competing Interests been migrated to a custom card yet?"
      end
      CardContent.transaction do
        card_contents.each do |content|
          result = content.update(text: "Please provide details about any and all competing interests in the box below. Your response should begin with this statement: \"I have read the journal's policy and the authors of this manuscript have the following competing interests.\"<br><br>Please note that if your manuscript is accepted, this statement will be published.")
          unless result
            raise Exception "Failed to update Card Content #{content.id}."
          end
        end
      end
    end
  end
end
