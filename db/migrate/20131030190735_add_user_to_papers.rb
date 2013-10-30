class AddUserToPapers < ActiveRecord::Migration
  def change
    add_reference :papers, :user, index: true
  end
end
