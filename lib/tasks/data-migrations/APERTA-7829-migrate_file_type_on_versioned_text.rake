namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-7829: Updates stored file types on versioned_text
    DESC
    task migrate_file_type_on_versioned_text: :environment do
      VersionedText.update_all file_type: 'docx'
      STDOUT.puts('Data migration completed')
    end
  end
end

