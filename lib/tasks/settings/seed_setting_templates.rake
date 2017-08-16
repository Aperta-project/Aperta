namespace :settings do
  desc "create entries in the template_settings table"
  # Since Settings can belong to any type of owner, we need to have some
  # place to define what Settings a given owner will have at runtime.
  # This includes possible values and a default value
  # For the time being the ithenticate_automation setting is the only entry.
  task seed_setting_templates: :environment do
    [{ journal: nil,
       key: "TaskTemplate:TahiStandardTasks::SimilarityCheckTask",
       value_type: "string",
       global: true,
       setting_klass: "Setting",
       setting_name: "ithenticate_automation",
       value: "off",
       possible_setting_values: [
         "off",
         "at_first_full_submission",
         "after_any_first_revise_decision",
         "after_minor_revise_decision",
         "after_major_revise_decision"
       ] }].each do |hash|
      SettingTemplate.transaction do
        possible_values = hash.delete(:possible_setting_values) { |_el| [] }
        template_value = hash.delete(:value)
        s = SettingTemplate.find_or_initialize_by(hash)
        s.value = template_value
        s.save!
        value_type = hash[:value_type]
        possible_values.each do |v|
          PossibleSettingValue.create(
            value_type: value_type,
            value: v,
            setting_template: s
          )
        end
      end
    end
  end
end
