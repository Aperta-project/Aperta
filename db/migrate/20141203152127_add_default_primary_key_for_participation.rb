class AddDefaultPrimaryKeyForParticipation < ActiveRecord::Migration

  class Participation < ActiveRecord::Base
  end
  class ParticipationTemp < ActiveRecord::Base
  end

  def up
    create_table :participation_temps do |t|
      t.belongs_to :task
      t.belongs_to :user
      t.timestamps
    end

    Participation.all.each do |p|
      pt = ParticipationTemp.create(user_id: p.user_id, task_id: p.task_id)
      pt.update_columns(created_at: p.created_at, updated_at: p.updated_at)
    end

    drop_table :participations
    rename_table :participation_temps, :participations
    add_index :participations, :task_id
    add_index :participations, :user_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
