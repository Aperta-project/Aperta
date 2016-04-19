# Gets a list of user ids for people that are @mentioned in a body
class UserMentions
  def initialize(body, poster)
    @body = body
    @poster = poster
  end

  def people_mentioned
    @people_mentioned ||=
      User.where('lower(username) IN (?)', mentions_extracted_from_body)
  end

  def mentions_extracted_from_body
    Twitter::Extractor.extract_mentioned_screen_names(@body).uniq
      .map(&:downcase) - [@poster.username.downcase]
  end
end
