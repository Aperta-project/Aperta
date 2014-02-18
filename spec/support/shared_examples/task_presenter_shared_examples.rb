shared_examples_for "all tasks, which have common attributes" do
  let(:assignee_id) { task.assignee_id }
  let(:assignees) { User.admins_for(task.paper.journal).map { |u| [u.id, u.full_name] } }

  it "returns a hash of data used to render an overlay" do
    expect(TaskPresenter.for(task).data_attributes).to include(
      'paperTitle' => task.paper.title,
      'paperPath' => paper_path(task.paper),
      'paperId' => task.paper.to_param,
      'taskPath' => paper_task_path(task.paper, task),
      'taskTitle' => task.title,
      'taskBody' => task.body,
      'taskCompleted' => task.completed?,
      'cardName' => card_name,
      'assigneeId' => assignee_id,
      'assignees' => assignees,
      'taskId' => task.id
    )
  end
end
