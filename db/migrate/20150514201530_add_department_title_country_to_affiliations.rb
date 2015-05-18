class AddDepartmentTitleCountryToAffiliations < ActiveRecord::Migration
  def change
    add_column :affiliations, :department, :string
    add_column :affiliations, :title, :string
    add_column :affiliations, :country, :string
  end
end
