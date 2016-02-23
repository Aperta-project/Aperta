namespace 'nested-questions:seed' do
  task 'authors-task': :environment do
    questions = []
    questions << {
      owner_id:nil,
      owner_type: TahiStandardTasks::AuthorsTask.name,
      ident: 'authors--persons_agreed_to_be_named',
      value_type: 'boolean',
      text: 'Any persons named in the Acknowledgements section of the manuscript, or referred to as the source of a personal communication, have agreed to being so named.',
      position: 1,
      children: []
    }

    questions << {
      owner_id:nil,
      owner_type: TahiStandardTasks::AuthorsTask.name,
      ident: 'authors--authors_confirm_icmje_criteria',
      value_type: 'boolean',
      text: 'All authors have read, and confirm, that they meet, ICMJE criteria for authorship.',
      position: 2,
      children: []
    }

    questions << {
      owner_id:nil,
      owner_type: TahiStandardTasks::AuthorsTask.name,
      ident: 'authors--authors_agree_to_submission',
      value_type: 'boolean',
      text: 'All contributing authors are aware of and agree to the submission of this manuscript.',
      position: 3,
      children: []
    }

    NestedQuestion.where(
      owner_type: TahiStandardTasks::AuthorsTask.name
    ).update_all_exactly!(questions)
  end
end
