shared_examples_for "all tasks, which have common attributes" do
  let(:assignee_id) { task.assignee_id }
  let(:assignees) { User.admins.map { |u| [u.id, u.full_name] }.to_json }

  it "returns a hash of data used to render an overlay" do
    expect(TaskPresenter.for(task).data_attributes).to include(
      'paper-title' => task.paper.title,
      'paper-path' => paper_path(task.paper),
      'paper-id' => task.paper.to_param,
      'task-path' => paper_task_path(task.paper, task),
      'task-title' => task.title,
      'task-body' => task.body,
      'card-name' => card_name,
      'assignee-id' => assignee_id,
      'assignees' => assignees,
      'task-id' => task.id
    )
  end
end
