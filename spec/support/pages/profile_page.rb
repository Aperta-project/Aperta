class ProfilePage < Page
  path :profile

  def full_name
    find('#profile-name').text
  end

  def username
    find('#profile-username h2').text
  end

  def email
    all('#profile-email h2').last.text
  end

  def set_affiliate name
    find('a', text: 'ADD NEW AFFILIATION').click
    fill_in("Affiliation Name", with: name)
  end

  def add_affiliate(name)
    set_affiliate name
    click_button "done"
  end

  def remove_affiliate(name)
    page.find(".profile-affiliation-name", text: name).parent.find('.remove-affiliation').click
    page.driver.browser.switch_to.alert.accept
  end

  def affiliations
    all('.profile-affiliation-name').map(&:text)
  end

  def has_affiliations?(*affiliations)
    affiliations.all? do |a|
      page.has_css? '.profile-affiliation-name', text: a
    end
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
