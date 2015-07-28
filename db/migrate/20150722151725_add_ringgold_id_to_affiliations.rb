class AddRinggoldIdToAffiliations < ActiveRecord::Migration
  def change
    add_column :affiliations, :ringgold_id, :string
  end
end
