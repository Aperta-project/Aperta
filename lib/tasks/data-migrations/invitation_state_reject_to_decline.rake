namespace :data do
  namespace :migrate do
    namespace :invitation_update_reject_to_decline do
      desc 'Change rejected invitation state to declined'
      task set_roles_to_editor: :environment do
        Invitation.where(state: 'rejected').each do |invitation|
          invitation.update_column(:state, 'declined')
        end
      end
    end
  end
end
