FactoryGirl.define do
  factory :plos_authors_task, class: 'PlosAuthors::PlosAuthorsTask' do
    phase
    title "Add Authors"
    role "author"
  end
end

