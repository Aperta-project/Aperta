# Adds necessary field for include ProxyableResource, namely token and
# then updating previous figures
class AddTokenToFigures < ActiveRecord::Migration
  # stands in for model, ensures that regenerate_token is defined
  class Figure < ActiveRecord::Base
    def regenerate_token
      update_attributes! token: SecureRandom.hex(24)
    end
  end

  def change
    Figure.reset_column_information

    add_column :figures, :token, :string
    add_index :figures, :token, unique: true

    reversible do |dir|
      dir.up do
        puts "Adding tokens for #{Figure.all.count} previous figures in db..."
        Figure.all.each(&:regenerate_token)
        puts 'Done.'
      end
    end

  end
end
