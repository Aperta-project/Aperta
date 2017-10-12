namespace :data do
  namespace :migrate do
    desc <<-DESC
      Rename card content "text" content type to "description"
    DESC
      task aperta_11251_change_text_content_type_to_description: :environment do
        CardContents.where(content_type: "text").update_all(content_type: "description")
      end
  end
end
