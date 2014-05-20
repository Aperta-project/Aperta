class Survey < ActiveRecord::Base
  include EventStreamNotifier

  belongs_to :declaration_task, class_name: "DeclarationTask", foreign_key: 'task_id', inverse_of: :surveys

  private

  def task_payload
    { task_id: declaration_task.id, paper_id: declaration_task.paper.id }
  end
end
