namespace 'nested-questions:seed' do
  task 'reviewer-recommendation': :environment do
    questions = []
    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: TahiStandardTasks::ReviewerRecommendation.name,
      ident: "reviewer_recommendations.recommend_or_oppose",
      value_type: "boolean",
      text: "Are you recommending or opposing this reviewer? (required)",
      position: 1
    )
    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: TahiStandardTasks::ReviewerRecommendation.name,
      ident: "reviewer_recommendations.reason",
      value_type: "text",
      text: "Optional: reason for recommending or opposing this reviewer",
      position: 2
    )

    questions.each do |q|
      unless NestedQuestion.where(owner_id:nil, owner_type:TahiStandardTasks::ReviewerRecommendation.name, ident:q.ident).exists?
        q.save!
      end
    end
  end
end
