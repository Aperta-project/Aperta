class BiologyAllowsMsword < ActiveRecord::Migration
  def change
    journal = Journal.find_by(name: "PLOS Biology")
    return unless journal

    journal.update_attributes!(msword_allowed: true)
  end
end
