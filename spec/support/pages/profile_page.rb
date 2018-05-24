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
    page.find(".profile-affiliation-name", text: name).query_scope.find('.affiliation-remove').click
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
