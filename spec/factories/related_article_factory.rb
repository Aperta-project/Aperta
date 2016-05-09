# coding: utf-8
FactoryGirl.define do
  factory :related_article do
    paper

    linked_doi "journal.pcbi.1004816"
    linked_title "ISCB’s Initial Reaction to The New England Journal of Medicine Editorial on Data Sharing"
    additional_info "This is a paper I picked at random from the internet"
    send_manuscripts_together false
    send_link_to_apex true
  end
end
