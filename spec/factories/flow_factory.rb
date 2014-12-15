FactoryGirl.define do
  factory :flow do
    title 'Up for grabs'
    role

    trait(:default) do
      role nil
    end
  end
end

