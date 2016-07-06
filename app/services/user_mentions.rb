# Gets a list of user ids for people that are @mentioned in a body
class UserMentions
  def initialize(body, poster, permission_object: nil)
    @body = body
    @permission_object = permission_object
    @poster = poster
  end

  def all_users_mentioned
    @people_mentioned ||=
      User.where('lower(username) IN (?)', mentions_extracted_from_body)
  end

  def notifiable_users_mentioned
    @valid_people_mentioned ||= begin
      return all_users_mentioned unless @permission_object
      all_users_mentioned.select do |user|
        user.can? :be_at_mentioned, @permission_object
      end
    end
  end

  def mentions_extracted_from_body
    Twitter::Extractor.extract_mentioned_screen_names(@body).uniq
      .map(&:downcase) - [@poster.username.downcase]
  end

  def decorated_mentions
    new_body = @body.clone
    notifiable_users_mentioned.each do |person|
      new_body.gsub!("@#{person.username}", tag_for_user(person))
    end
    new_body
  end

  def tag_for_user(user)
    <<-HTML.gsub!(/\s+/, " ").strip
      <a class="discussion-at-mention"
         data-user-id="#{user.id}"
         title="#{user.full_name}">@#{user.username}</a>
    HTML
  end
end
