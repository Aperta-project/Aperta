namespace :figure do

  desc "Recreate all of the versions of figure attachments"
  task :recreate_attachments => :environment do
    Figure.all.each do |f|
      # in case we have dangling references to files that have been
      # deleted manually
      begin
        f.attachment.recreate_versions!
        f.save!
      rescue => e
        puts "Unable to recreate figure attachment versions, ignore #{e}"
      end
    end
  end
end
