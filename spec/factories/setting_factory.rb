FactoryGirl.define do
  factory :setting do
    name "override_me"
    value "off"
  end

  factory :ithenticate_automation_setting, class: "Setting::IthenticateAutomation" do
    name "ithenticate_automation"
    value "off"

    trait :at_first_full_submission do
      value "at_first_full_submission"
    end

    trait :after_any_first_revise_decision do
      value "after_any_first_revise_decision"
    end

    trait :after_first_minor_revise_decision do
      value "after_first_minor_revise_decision"
    end

    trait :after_first_major_revise_decision do
      value "after_first_major_revise_decision"
    end
  end
end
