FactoryGirl.define do
  factory :paper_role do
    trait(:admin) do
      role 'admin'
    end

    trait(:editor) do
      role 'editor'
    end

    trait(:reviewer) do
      role 'reviewer'
    end

    trait(:collaborator) do
      role 'collaborator'
    end

    trait(:participant) do
      role 'participant'
    end
  end
end
