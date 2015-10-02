class ConvertPlosAuthorsTaskType < ActiveRecord::Migration
  def up
    # update existing journal task types to new model name
    sql = %Q{
      UPDATE journal_task_types
      SET kind = 'TahiStandardTasks::AuthorsTask'
      WHERE kind = 'PlosAuthors::PlosAuthorsTask'
    }
    ActiveRecord::Base.connection.execute(sql)
  end

  def down
    # update existing journal task types to old model name
    sql = %Q{
      UPDATE journal_task_types
      SET kind = 'PlosAuthors::PlosAuthorsTask'
      WHERE kind = 'TahiStandardTasks::AuthorsTask'
    }
    ActiveRecord::Base.connection.execute(sql)
  end
end
