namespace 'nested-questions:seed' do
  task 'figure-task': :environment do
    questions = []
    questions << NestedQuestion.new(
      owner_id:nil,
      owner_type: TahiStandardTasks::FigureTask.name,
      ident: "figures.complies",
      value_type: "boolean",
      text: "Yes - I confirm our figures comply with the guidelines.",
      position: 1
    )

    questions.each do |q|
      unless NestedQuestion.where(owner_id:nil, owner_type:TahiStandardTasks::FigureTask.name, ident:q.ident).exists?
        q.save!
      end
    end
  end
end
