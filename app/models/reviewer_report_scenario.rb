class ReviewerReportScenario < PaperScenario
  def review
    ReviewerReportContext.new(review_object)
  end

  def reviewer
    UserContext.new(review_object.user)
  end

  private

  def review_object
    @object
  end

  def manuscript_object
    review_object.paper
  end
end
