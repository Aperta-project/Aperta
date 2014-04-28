class Survey < ActiveRecord::Base
  include EventStreamNotifier

  belongs_to :declaration_task, class_name: "DeclarationTask", foreign_key: 'task_id', inverse_of: :surveys

  private

  def id_for_stream
    declaration_task.id
  end
end
