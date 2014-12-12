FactoryGirl.define do
  factory :flow do
    title 'Up for grabs'
    query state: :completed
    role

    trait(:default) do
      role nil
    end
  end

  
end

