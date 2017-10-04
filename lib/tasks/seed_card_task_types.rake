namespace :card_task_types do
  desc "create default CardTaskTypes and associate any orphan cards"
  task seed: :environment do
    Card.transaction do
      CardTaskType.seed_defaults
      ctt_id = CardTaskType.find_by!(task_class: 'CustomCardTask').id
      Card.where(card_task_type_id: nil).update_all(card_task_type_id: ctt_id) # rubocop:disable Rails/SkipsModelValidations
    end
  end
end
