namespace :data do
  desc "create registry entries in the registered_settings table"
  task seed_registered_settings: :environment do
    [{ journal: nil,
       key: "TaskTemplate:TahiStandardTasks::SimilarityCheckTask",
       global: true,
       setting_klass: "Setting::Ithenticate",
       setting_name: "ithenticate" }].each do |hash|
      RegisteredSetting.find_or_create_by!(hash)
    end
  end
end
