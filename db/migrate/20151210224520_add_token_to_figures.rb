# Adds necessary field for include ProxyableResource, namely token and
# then updating previous figures
class AddTokenToFigures < ActiveRecord::Migration
  def change
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
