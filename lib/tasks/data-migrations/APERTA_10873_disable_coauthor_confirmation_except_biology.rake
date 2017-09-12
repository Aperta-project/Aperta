namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-11027: disable_coauthor_confirmation_except_biology

      There is a setting template which sets the default value of "coauthor_confirmation_enabled"
      to false for all journals. We want to set it true only for PLOS Biology
    DESC

    task APERTA_10873_disable_coauthor_confirmation_except_biology: [:environment, "settings:seed_setting_templates"] do
      journal = Journal.find_by(name: "PLOS Biology")
      if journal
        journal.setting("coauthor_confirmation_enabled").update(value: true)
      else
        puts "No Journal was found with the name 'PLOS Biology'. No coauthor confirmation setting created"
      end
    end
  end
end
