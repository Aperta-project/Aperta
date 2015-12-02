# Adds necessary stuff for tokens
class AddTokenToSupportingInformationFile < ActiveRecord::Migration
  def change
    add_column :supporting_information_files, :token, :string
    add_index :supporting_information_files, :token, unique: true

    reversible do |dir|
      dir.up do
        puts "Adding tokens for #{SupportingInformationFile.all.count} previous supporting_information_files..."
        SupportingInformationFile.all.each {|file| file.regenerate_token }
        puts 'Done.'
      end
    end

  end
end
