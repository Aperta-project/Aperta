class AddPositionValuesToPhase < ActiveRecord::Migration
  def up
    # migrate existing task.position to the new phase.task_positions array
    migrate_sql = %Q{
      UPDATE phases
      SET task_positions = ordered_tasks.ids
      FROM (
        SELECT phase_id, array_agg(id) AS ids
        FROM tasks
        GROUP BY phase_id
      ) AS ordered_tasks
      WHERE id = ordered_tasks.phase_id;
    }.squish

    ActiveRecord::Base.connection.execute(migrate_sql)
  end

  def down
    migrate_sql = %Q{
      UPDATE phases
      SET task_positions = '{}'
    }.squish

    ActiveRecord::Base.connection.execute(migrate_sql)
  end

end
