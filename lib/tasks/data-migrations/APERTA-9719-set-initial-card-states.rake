namespace :data do
  namespace :migrate do
    namespace :cards do
      desc 'Sets the state of each card to draft in preparation for adding a null constraint to the state column'
      task set_initial_states: :environment do
        Card.all.update_all(state: 'draft')
      end

      desc 'Resets the state column to nil for cards'
      task unset_initial_states: :environment do
        Card.all.update_all(state: nil)
      end
    end
  end
end
