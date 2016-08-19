# This is a hot-fix for part of APERTA-7470. See the rake task description
# for more information.
class BackFillRegisterDecisionLetterSelections < DataMigration
  RAKE_TASK_UP = 'data:migrate:set_register_decision_letter_answers'
end
