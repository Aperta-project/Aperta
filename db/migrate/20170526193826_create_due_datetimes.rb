class CreateDueDatetimes < ActiveRecord::Migration
  def change
    create_table :due_datetimes do |t|

      # in the future, we want to allow other objects to have due 'dates'
      t.references :due, polymorphic: true, index: true

      t.datetime :due_at

      # this should be set once and never changed.
      t.datetime :originally_due_at
      # the due 'date' can be extended, in which case these would differ

      # this would be valuable if there is ever a need to recompute a due date
      # and for some reason :created_at could not be relied upon.
      # at the moment I cannot think of a scenario where I'm sure that :created_at
      # would be changed (e.g. it should be preserved through a db dump & restore, etc.)
      # t.datetime :set_at

      t.timestamps null: false
    end
  end
end
