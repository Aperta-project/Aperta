# Adds necessary stuff for tokens
class AddTokenToSupportingInformationFile < ActiveRecord::Migration
  # A Mock
  class Figure < ActiveRecord::Base
    def regenerate_token
      update_attributes! token: SecureRandom.hex(24)
    end
  end

  def change
    Figure.reset_column_information
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
