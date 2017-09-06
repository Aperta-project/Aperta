namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-11027: Adisable_coauthor_confirmation_except_biology

      Create a boolean setting on all existing journals that enables or disables coauthor confirmation.
      It should be set to false for all journals besides biology
    DESC

    task APERTA_10873_disable_coauthor_confirmation_except_biology: :environment do
      Journal.all.each do |journal|
        value = journal.name == "PLOS biology" ? true : false

        journal.settings.create(name: "coauthor_confirmation_enabled",
                                value_type: 'boolean',
                                boolean_value: value)
      end
    end
  end
end
