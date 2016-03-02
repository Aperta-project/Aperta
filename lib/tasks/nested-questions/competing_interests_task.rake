namespace 'nested-questions:seed' do
  task 'competing-interests-task': :environment do
    questions = []
    questions << {
      owner_id:nil,
      owner_type: TahiStandardTasks::CompetingInterestsTask.name,
      ident: "competing_interests--has_competing_interests",
      value_type: "boolean",
      text: "Do any authors of this manuscript have competing interests (as described in the <a target='_blank' href='http://journals.plos.org/plosbiology/s/competing-interests'>PLOS Policy on Declaration and Evaluation of Competing Interests</a>)?",
      position: 1,
      children: []
    }

    statement = {
      owner_id:nil,
      owner_type: TahiStandardTasks::CompetingInterestsTask.name,
      ident: "competing_interests--statement",
      value_type: "text",
      text: "Please provide details about any and all competing interests in the box below. Your response should begin with this statement: \"I have read the journal's policy and the authors of this manuscript have the following competing interests.\"",
      position: 2
    }
    questions.last[:children] << statement

    NestedQuestion.where(
      owner_type: TahiStandardTasks::CompetingInterestsTask.name
    ).update_all_exactly!(questions)
  end
end
