namespace :data do
  desc "Add positions to author groups for acts_as_list"
  task :add_author_positions => :environment do
    AuthorGroup.all.each do |ag|
      ag.authors.each_with_index do |author, index|
        author.position = index + 1
        author.save
      end
    end
  end
end
