namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-10097: Competing Interests custom card text fix

      The original Competing Interests conversion had a text error in XML that was loaded. This
      patches that in the CardContent records that were created.
    DESC

    task aperta_10097_competing_interests_text_fix: :environment do
      DataTransformation::FixXmlTextNodeValues.new.call
    end
  end
end
