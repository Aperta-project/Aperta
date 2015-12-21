FactoryGirl.define do
  factory :paper_role do
    user
    paper

    trait(:admin) do
      old_role 'admin'
    end

    trait(:editor) do
      old_role 'editor'
    end

    trait(:reviewer) do
      old_role 'reviewer'
    end

    trait(:collaborator) do
      old_role 'collaborator'
    end

    trait(:participant) do
      old_role 'participant'
    end
  end
end
