FactoryGirl.define do
  factory :bibitem do
    paper
    format "citeproc"
    sequence(:content) { |n| "{ \"doi\": \"#{n}\" }" }
  end
end
