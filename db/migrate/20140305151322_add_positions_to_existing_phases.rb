class AddPositionsToExistingPhases < ActiveRecord::Migration
  def up
    if defined? TaskManager
      TaskManager.all.each do |tm|
        tm.phases.map.with_index do |phase, pos|
          if phase.position.blank?
            phase.position = pos
            phase.save
          end
        end
      end
    end
  end

  def down
    #there is no down.
  end
end
