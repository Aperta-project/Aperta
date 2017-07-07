FactoryGirl.define do
  factory :setting_template do
    key "test_key"
    value_type "string"
    setting_klass "Setting"
    setting_name "on"
    global true

    trait :with_possible_values do
      transient do
        possible_values []
      end

      after(:create) do |template, evaluator|
        evaluator.possible_values.each do |v|
          template.possible_setting_values << PossibleSettingValue.create(
            value_type: template.value_type,
            value: v
          )
        end
      end
    end
  end
end
