namespace 'nested-questions:seed' do
  task 'reviewer-recommendation': :environment do
    questions = []
    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::ReviewerRecommendation.name,
      ident: "reviewer_recommendations--recommend_or_oppose",
      value_type: "boolean",
      text: "Are you recommending or opposing this reviewer?",
      position: 1
    }
    questions << {
      owner_id: nil,
      owner_type: TahiStandardTasks::ReviewerRecommendation.name,
      ident: "reviewer_recommendations--reason",
      value_type: "text",
      text: "Optional: reason for recommending or opposing this reviewer",
      position: 2
    }

    NestedQuestion.where(
      owner_type: TahiStandardTasks::ReviewerRecommendation.name
    ).update_all_exactly!(questions)
  end
end
