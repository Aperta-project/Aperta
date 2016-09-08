namespace :data do
  namespace :migrate do
    namespace :invitations do
      desc <<-DESC
        Populates invited_at and declined_at

        This populates invited_at based upon the created_at date of the invitation.
        It also populates declined_at based upon the update_at column of the invitation.
        It is important to track these two values before we implement queueing.
      DESC

      task populate_dates: :environment do
        Invitation.all.find_each do |invitation|
          invitation.update_column(:invited_at, invitation.created_at)
        end
        Invitation.where(state: 'declined').find_each do |invitation|
          invitation.update_column(:declined_at, invitation.updated_at)
        end
        Invitation.where(state: 'accepted').find_each do |invitation|
          invitation.update_column(:accepted_at, invitation.updated_at)
        end
      end
    end
  end
end
