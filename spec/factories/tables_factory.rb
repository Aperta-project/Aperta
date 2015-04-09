FactoryGirl.define do
  factory :table do
    paper
    sequence(:title) { |n| "Title #{n}" }
    sequence(:caption) { |n| "Caption #{n}" }
    body "<table><tr><td>1</td><td>2</td><td>3</td></tr></table>"
  end
end
