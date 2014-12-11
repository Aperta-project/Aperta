class RemoveIhatJobModel < ActiveRecord::Migration
  def change
    drop_table :ihat_jobs
  end
end
