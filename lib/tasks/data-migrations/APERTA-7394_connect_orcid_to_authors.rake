namespace :data do
  namespace :migrate do
    namespace :authors do
      desc <<-DESC
        APERTA-7394: Tries to match up author records where the author was the
        creator with a corresponding user record. This is for ORCiD
        integration.
      DESC
      task connect_creators_with_user_record: :environment do
        ::Paper.find_in_batches do |papers|
          papers.each do |paper|
            creator = paper.creator

            if creator.blank?
              msg = <<-WARN.strip_heredoc
                Paper id=#{paper.id} has no creator. This is likely bad data
                  and this paper should be considered for deletion.
              WARN
              Rails.logger.warn msg
              puts msg, ""
              next
            end

            authors = paper.authors.reorder('author_list_items.position ASC')
            creator_author = authors.detect do |author|
              author.email == paper.creator.email || author.full_name == paper.creator.full_name
            end

            if creator_author
              creator_author.update_attribute(:user_id, creator.id)
            else
              msg = <<-WARN.strip_heredoc
                Paper id=#{paper.id} cannot find an author record whose email matches the MS creator's email (#{creator.email})
                Possible authors are:
                #{paper.authors.map(&:email)}
              WARN
              Rails.logger.warn msg
              puts msg, ""
            end
          end
        end
      end

      desc <<-DESC
        APERTA-7394: Disconnects author records from user records
        by setting user_id to NULL for every author record.
      DESC
      task disconnect_creators_from_user_record: :environment do
        ::Author.update_all(user_id: nil)
      end
    end
  end
end
