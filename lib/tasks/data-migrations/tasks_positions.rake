namespace :data do
  namespace :migrate do
    namespace :tasks do
      desc 'Sets the Task position value based on actual ordering'
      task reset_positions_value: :environment do
        Phase.all.each do |phase|
          phase.tasks.order(:position).each_with_index do |task, index|
            task.update_column(:position, index + 1)
          end
        end
      end
    end
  end
end
