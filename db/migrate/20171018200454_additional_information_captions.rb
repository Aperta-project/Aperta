class AdditionalInformationCaptions < ActiveRecord::Migration
  IDENT = "publishing_related_questions--published_elsewhere--upload_related_work".freeze

  def content
    CardContent.where(ident: IDENT)
  end

  def change_attr(val)
    logger.info "updating #{content.size} pieces of content with ident #{IDENT}"
    content.each do |c|
      c.allow_file_captions = val
      c.save!
    end
  end

  def up
    change_attr true
  end

  def down
    change_attr false
  end
end
