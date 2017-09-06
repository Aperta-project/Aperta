namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-11027: Adisable_coauthor_confirmation_except_biology

      Create a boolean setting on all existing journals that enables or disables coauthor confirmation.
      It should be set to false for all journals besides biology
    DESC

    task APERTA_10873_disable_coauthor_confirmation_except_biology: [:environment, "settings:seed_setting_templates"] do

      Journal.find_by!(name: "PLOS Biology").setting("coauthor_confirmation_enabled")
        .update(value: true)
    end
  end
end
