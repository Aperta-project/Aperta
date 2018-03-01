module TahiStandardTasks
  class ReviewerRecommendationSerializer < AuthzSerializer
    include CardContentShim
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

    private

    # TODO: APERTA-12693 Stop overriding this
    def can_view?
      true
    end
  end
end
