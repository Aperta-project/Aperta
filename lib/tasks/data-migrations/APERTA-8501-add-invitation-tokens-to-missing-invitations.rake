namespace :data do
  namespace :migrate do
    namespace :invitations do
      desc 'Adds an invitation token to all invations.  This is necessary to add a unique constraint in the database'
      task add_invitation_tokens: :environment do
        ActiveRecord::Base.transaction do
          max_retries = 5
          token = SecureRandom.hex(10)
          Invitation.where("token is null").each do |invitation|
            tries = 0
            loop do
              token = SecureRandom.hex(10)
              break unless Invitation.where(token: token).exists?
              tries += 1
              raise "Cannot generate invitation tokens" if tries > max_retries
            end
            invitation.token = token
            invitation.save!
          end
        end
      end
    end
  end
end
