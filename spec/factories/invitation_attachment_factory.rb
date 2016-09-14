FactoryGirl.define do
  factory :invitation_attachment, parent: :attachment, class: 'InvitationAttachment' do
    association :owner, factory: :invitation
  end
end
