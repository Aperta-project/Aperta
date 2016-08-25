class ProfilePage < Page
  path :root
  text_assertions :affiliation, '.profile-affiliation-name'
  text_assertions :full_name, '#profile-name'
  text_assertions :username, '#profile-username h2'
  text_assertions :email, '#profile-email h2'

  def full_name
    find('#profile-name')
  end

  def username
    find('#profile-username h2')
  end

  def email
    all('#profile-email h2').last
  end

  def start_adding_affiliate
    find('a', text: 'ADD NEW AFFILIATION').click
  end

  def fill_in_email(email)
    find('input[placeholder="Email Address"]').set(email)
  end

  def submit
    click_button "done"
  end

  def remove_affiliate(name)
    page.find(".profile-affiliation-name", text: name).parent.find('.affiliation-remove').click
    page.driver.browser.switch_to.alert.accept
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
