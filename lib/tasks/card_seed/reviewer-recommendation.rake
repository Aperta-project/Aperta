require_relative './support/card_seeder'
namespace 'card_seed' do
  task 'reviewer_recommendation': :environment do
    content = []
    content << {
      ident: "reviewer_recommendations--recommend_or_oppose",
      value_type: "boolean",
      text: "Are you recommending or opposing this reviewer?"
    }
    content << {
      ident: "reviewer_recommendations--reason",
      value_type: "text",
      text: "Optional: reason for recommending or opposing this reviewer"
    }

    CardSeeder.seed_card('TahiStandardTasks::ReviewerRecommendation', content)
  end
end
