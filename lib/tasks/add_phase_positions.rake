desc "Add default positions to phases that are already in the db"
task :add_phase_positions => :environment do
  TaskManager.all.each do |tm|
    tm.phases.map.with_index do |phase, pos|
      if phase.position.blank?
        phase.position = pos
        phase.save
      end
    end
  end
end
