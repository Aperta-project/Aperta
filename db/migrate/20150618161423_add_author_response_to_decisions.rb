class AddAuthorResponseToDecisions < ActiveRecord::Migration
  def change
    add_column :decisions, :author_response, :text
  end
end
