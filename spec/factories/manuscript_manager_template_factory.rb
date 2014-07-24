FactoryGirl.define do

  factory :manuscript_manager_template do
    sequence(:paper_type) {|n| "Research #{n}" }
    template do
      {
        phases: [{
          name: "Editorial",
          task_types: [StandardTasks::FigureTask.to_s]
        }]
      }
    end
  end

end
