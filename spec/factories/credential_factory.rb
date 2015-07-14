FactoryGirl.define do
  factory :orcid_credential, class: Credential do
    provider "orcid"
    uid "abc123"
  end

  factory :cas_credential, class: Credential do
    provider "cas"
    # matches the vcr cassette for ned
    uid "00000000-f8d2-4a8d-b8e4-21aa01a81aab"
  end
end
