FactoryGirl.define do
  factory :flow do
    title 'Up for grabs'
    old_role

    trait(:default) do
      old_role nil
    end
  end
end

