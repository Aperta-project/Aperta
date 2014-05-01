class ProfilePage < Page
  path :profile
  def user_full_name
    find('#profile-name h1').text
  end

  def username
    find('#profile-username h2').text
  end

  def email
    all('#profile-email h4').last.text
  end

  def affiliations
    all('#profile-affiliations h4').map(&:text)[1..-1]
  end
end
