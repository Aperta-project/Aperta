module TahiStandardTasks
  class ReviewerRecommendationSerializer < ActiveModel::Serializer
    attributes :id,
               :first_name,
               :middle_initial,
               :last_name,
               :email,
               :title,
               :department,
               :affiliation,
               :ringgold_id,
               :recommend_or_oppose,
               :reason
  end
end
