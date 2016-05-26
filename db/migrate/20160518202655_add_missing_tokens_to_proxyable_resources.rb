class AddMissingTokensToProxyableResources < ActiveRecord::Migration
  class Figure < ActiveRecord::Base
    def regenerate_token
      update_columns token: SecureRandom.hex(24)
    end
  end
  class SupportingInformationFile < ActiveRecord::Base
    def regenerate_token
      update_columns token: SecureRandom.hex(24)
    end
  end
  class QuestionAttachment < ActiveRecord::Base
    def regenerate_token
      update_columns token: SecureRandom.hex(24)
    end
  end

  def add_missing_tokens(klass)
    query = klass.where(token: nil)
    return if query.count == 0

    puts "Adding missing #{query.count} tokens to #{klass.name.demodulize} records..."
    query.each(&:regenerate_token)
    puts 'Done.'
  end

  def change
    Figure.reset_column_information
    SupportingInformationFile.reset_column_information
    QuestionAttachment.reset_column_information

    reversible do |dir|
      dir.up do
        [Figure, SupportingInformationFile, QuestionAttachment].each do |klass|
          add_missing_tokens(klass)
        end
      end
    end
  end
end
