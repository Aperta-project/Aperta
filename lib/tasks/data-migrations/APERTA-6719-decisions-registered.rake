namespace :data do
  namespace :migrate do
    namespace :decisions do
      desc 'Sets "registered" flag on decisions'
      task set_registered_flag: :environment do
        # The only decisions that have not been registered are pending decisions.
        # Pending decisions are always the latest decisions.
        # Papers in terminal states (accept, reject) do not have pending decisions.
        Decision.all.update_all(registered: true)
        Paper.all.each do |paper|
          paper.decisions.latest.update(registered: false) unless paper.in_terminal_state?
        end
      end
    end
  end
end
