namespace :orphaned_participations do
  desc "Removes participations whose users no longer exist"
  task :remove => :environment do
    Participation.all.each do |p|
      p.destroy if p.user.nil?
    end
  end
end
