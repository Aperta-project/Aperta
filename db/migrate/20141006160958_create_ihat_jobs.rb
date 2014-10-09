class CreateIhatJobs < ActiveRecord::Migration
  def change
    create_table :ihat_jobs do |t|
      t.belongs_to :paper, index: true
      t.string :job_id

      t.timestamps
    end
  end
end
