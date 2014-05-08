class AddEmailToAffiliations < ActiveRecord::Migration
  def change
    add_column :affiliations, :email, :string
  end
end
