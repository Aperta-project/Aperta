shared_examples_for "all tasks, which have common attributes" do
  it "returns a hash of data used to render an overlay" do
    expect(TaskPresenter.for(task).data_attributes).to include(
      'paper-title' => task.paper.title,
      'paper-path' => paper_path(task.paper),
      'paper-id' => task.paper.to_param,
      'task-path' => paper_task_path(task.paper, task),
      'card-name' => card_name
    )
  end
end
