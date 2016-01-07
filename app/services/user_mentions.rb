# Gets a list of user ids for people that are @mentioned in a body
class UserMentions
  def initialize(body, poster)
    @body = body
    @poster = poster
  end

  # uses the same format as
  # https://dev.twitter.com/overview/api/entities-in-twitter-objects#user_mentions
  def set_mentions
    self.entities = {
      user_mentions: Twitter::Extractor
        .extract_mentioned_screen_names_with_indices(@body) }
  end

  def people_mentioned
    @people_mentioned ||= User.where(username: mentions_extracted_from_body)
  end

  def mentions_extracted_from_body
    Twitter::Extractor.extract_mentioned_screen_names(@body).uniq
      .map(&:downcase) - [@poster.username.downcase]
  end
end
