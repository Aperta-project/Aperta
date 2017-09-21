namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-10458: swap fieldset with display-children (field-set)

      We decided to remove the CC list and fieldset types from the project.  However,
      We have one existing card (Competing Interests) that's in prod right now that's
    DESC
    task aperta_10458_swap_fieldset_with_display_children: :environment do
      DataTransformation::ReplaceFieldSetCardContentTypes.new.call
    end
  end
end
