# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

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
      <a title="#{user.full_name}">@#{user.username}</a>
    HTML
  end
end
