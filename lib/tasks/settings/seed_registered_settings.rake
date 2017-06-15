namespace :settings do
  desc "create registry entries in the registered_jksettings table"
  # Since Settings can belong to any type of owner, we need to have some
  # place to define what Settings a given owner will have at runtime.
  # For the time being the ithenticate_automation setting is the only entry.
  # In the near future it'll probably make sense to store a default value on
  # the RegisteredSetting record as well to account for things like Boolean settings that may default to true or false depending on context
  task seed_registered_settings: :environment do
    [{ journal: nil,
       key: "TaskTemplate:TahiStandardTasks::SimilarityCheckTask",
       global: true,
       setting_klass: "Setting::IthenticateAutomation",
       setting_name: "ithenticate_automation" }].each do |hash|
      RegisteredSetting.find_or_create_by!(hash)
    end
  end
end
