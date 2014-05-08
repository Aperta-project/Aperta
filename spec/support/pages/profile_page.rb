class ProfilePage < Page
  path :profile

  def full_name
    find('#profile-name h1').text
  end

  def username
    find('#profile-username h2').text
  end

  def email
    all('#profile-email h4').last.text
  end

  def add_affiliate(name)
    find('#profile-affiliations').find(".btn-affiliation").click
    fill_in("Affiliation Name", with: name)
    find_button("done").click
  end

  def remove_affiliate(name)
    page.find("h4", text: name).parent.find('.remove-affiliation').click()
    page.driver.browser.switch_to.alert.accept
  end

  def affiliations
    find("#profile-affiliations").all('h4').map(&:text)[1..-1]
  end

  def attach_image(filename)
    page.execute_script "$('#profile-avatar-hover').css('display', 'block')"
    attach_file 'profile_avatar', Rails.root.join('spec', 'fixtures', filename), visible: false
  end

  def image
    find('#profile-avatar img')['src'].split('/').last
  end

  def image_size
    width = page.evaluate_script("$('#profile-avatar img').innerWidth()")
    height = page.evaluate_script("$('#profile-avatar img').innerHeight()")
    "#{width}x#{height}"
  end
end
