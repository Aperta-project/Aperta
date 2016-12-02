namespace :data do
  namespace :migrate do
    namespace :invitations do
      desc 'Adds an invitation token to all invations.  This is necessary to add a unique constraint in the database'
      task add_invitation_tokens: :environment do
        ActiveRecord::Base.transaction do
          token = SecureRandom.hex(10)
          Invitation.where("token is null").each do |invitation|
            loop do
              token = SecureRandom.hex(10)
              break unless Invitation.where(token: token).exists?
            end
            invitation.token = token
            invitation.save!
          end
        end
      end
    end
  end
end
