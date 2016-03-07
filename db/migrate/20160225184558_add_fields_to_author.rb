class AddFieldsToAuthor < ActiveRecord::Migration
  def change
    add_column :authors, :author_initial,          :string
    add_column :authors, :current_address_street,  :string
    add_column :authors, :current_address_street2, :string
    add_column :authors, :current_address_city,    :string
    add_column :authors, :current_address_state,   :string
    add_column :authors, :current_address_country, :string
    add_column :authors, :current_address_postal,  :string
  end
end
