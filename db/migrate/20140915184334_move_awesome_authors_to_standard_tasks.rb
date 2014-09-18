class MoveAwesomeAuthorsToStandardTasks < ActiveRecord::Migration
  def change
    rename_table :awesome_authors, :standard_tasks_awesome_authors
  end
end
