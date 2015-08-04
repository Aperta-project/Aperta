#! /usr/bin/env python2

from selenium.webdriver.common.by import By
from authenticated_page import AuthenticatedPage
import time

__author__ = 'jgray@plos.org'

class DashboardPage(AuthenticatedPage):
  """
  Model an aperta dashboard page
  """
  def __init__(self, driver, url_suffix='/'):
    super(DashboardPage, self).__init__(driver, url_suffix)

    # Locators - Instance members
    # Navigation Menu Locators
    self._nav_toggle = (By.CLASS_NAME, 'navigation-toggle')
    self._nav_close = (By.CLASS_NAME, 'navigation-close')
    self._nav_title = (By.CLASS_NAME, 'navigation-title')
    self._nav_profile_link = (By.CSS_SELECTOR, 'div.navigation a[href="/profile"]')
    self._nav_profile_img = (By.CSS_SELECTOR, 'div.navigation a[href="/profile"] img')
    self._nav_dashboard_link = (By.CSS_SELECTOR, 'div.navigation a[href="/"]')
    self._nav_flowmgr_link = (By.CSS_SELECTOR, 'div.navigation a[href="/flow_manager"]')
    self._nav_paper_tracker_link = (By.CSS_SELECTOR, 'div.navigation a[href="/paper_tracker"]')
    self._nav_admin_link = (By.CSS_SELECTOR, 'div.navigation a[href="/admin"]')
    self._nav_signout_link = (By.CSS_SELECTOR, 'div.navigation > a')
    self._nav_feedback_link = (By.CLASS_NAME, 'navigation-item-feedback')

    # Base Page Locators
    self._dashboard_title = (By.CSS_SELECTOR, 'h2.welcome-message')
    self._dashboard_create_new_submission_btn = (By.CSS_SELECTOR, 'button.button-primary.button--green')
    self._dashboard_paper_title = (By.CSS_SELECTOR, 'li.dashboard-paper-title a')
    self._dashboard_info_text = B=(By.CLASS_NAME, 'dashboard-info-text')

    self._click_view_invitations_button = (By.XPATH, './/div[2]/div[5]/section[1]/button')
    self._click_yes_to_invitations_button = (By.XPATH, './/div[3]/div/div/ul/li/button[1]')
    self._click_no_to_invitations_button = (By.XPATH, './/div[3]/div/div/ul/li/button[2]')
    self._check_for_one_invite_home = (By.XPATH, './/div[2]/div[5]/section[2]/h2')
    self._check_for_no_invites_home = (By.XPATH, './/div[2]/div[5]/section[2]/h2')
    self._check_error_assertion_failed = (By.CSS_SELECTOR, 'div.flash-message-content')

  #POM Actions
  def validate_initial_page_elements_styles(self):
    papers = []
    welcome_msg = self._get(self._dashboard_title)
    print(welcome_msg).text
    assert 'helvetica' in welcome_msg.value_of_css_property('font-family')
    assert welcome_msg.value_of_css_property('font-size') == '48px'
    assert welcome_msg.value_of_css_property('font-weight') == '500'
    assert welcome_msg.value_of_css_property('line-height') == '52.8px'
    assert welcome_msg.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'
    cns_btn = self._get(self._dashboard_create_new_submission_btn)
    assert cns_btn.text.lower() == 'create new submission'
    assert 'helvetica' in cns_btn.value_of_css_property('font-family')
    assert cns_btn.value_of_css_property('font-size') == '14px'
    assert cns_btn.value_of_css_property('font-weight') == '400'
    assert cns_btn.value_of_css_property('line-height') == '20px'
    assert cns_btn.value_of_css_property('color') == 'rgba(255, 255, 255, 1)'
    assert cns_btn.value_of_css_property('text-align') == 'center'
    assert cns_btn.value_of_css_property('text-transform') == 'uppercase'
    self.set_timeout(1)
    try:
      papers = self._gets(self._dashboard_paper_title)
    except:
      print('No papers present on user dashboard')
      self.restore_timeout()
    if papers:
      for paper in papers:
        self._actions.move_to_element(welcome_msg).perform()
        time.sleep(1)  # make sure the focus is not inadvertantly on a paper link
        print(paper.get_attribute('data-original-title'))
        assert paper.get_attribute('data-original-title') in [ 'Collaborator', 'Participant', 'My Paper',
                                                               'Collaborator, Participant',
                                                               'Collaborator, My Paper, Participant' ]
        assert 'librebaskerville' in paper.value_of_css_property('font-family')
        assert paper.value_of_css_property('font-size') == '18px'
        assert paper.value_of_css_property('line-height') == '27px'
        assert paper.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'
        self._actions.move_to_element(paper).perform()
        time.sleep(1)  # for some reason, it is taking a second for the transition to show, I blame Ember
        assert paper.value_of_css_property('color') == 'rgba(57, 163, 41, 1)', 'ERROR: Paper link color is ' + \
                                                                               paper.value_of_css_property('color')
    else:
      info_text = self._get(self._dashboard_info_text)
      assert info_text.text == 'Your scientific paper submissions will\nappear here.'
      assert 'helvetica' in info_text.value_of_css_property('font-family')
      assert info_text.value_of_css_property('font-size') == '24px'
      assert info_text.value_of_css_property('font-style') == 'italic'
      assert info_text.value_of_css_property('line-height') == '24px'
      assert info_text.value_of_css_property('color') == 'rgba(128, 128, 128, 1)'



  def click_create_new_submision_button(self):
    """Click Create new submission button"""
    self._get(self._dashboard_create_new_submission_btn).click()

  def click_left_nav(self):
    """Click left navigation"""
    self._get(self._nav_toggle).click()

  def validate_nav_elements(self, permissions):
    elevated = [ 'jgray_flowmgr', 'jgray' ]
    self._get(self._nav_close)
    self._get(self._nav_title)
    self._get(self._nav_profile_link)
    self._get(self._nav_profile_img)
    self._get(self._nav_dashboard_link)
    self._get(self._nav_signout_link)
    self._get(self._nav_feedback_link)
    # Must have flow mgr, admin or superadmin
    if permissions in elevated:
      self._get(self._nav_flowmgr_link)
      self._get(self._nav_paper_tracker_link)
    # Must have admin or superadmin
    if permissions == ( 'jgray_oa', 'jgray' ):
      self._get(self._nav_admin_link)

  def click_sign_out_link(self):
    """Click sign out link"""
    self._get(self._nav_signout_link).click()
    return self

# Examples of dynamic page display:
# Hi, Jeffrey. You have 2 manuscripts.
# [ Create New Submission ] button
# List of papers with links (papername, mouseover tooltip with role for paper displayed)

# Hi, Jeffrey MM. You have no manuscripts.
# [ Create New Submission ] button
# Your scientific paper submissions will appear here.

# connect to postgres, select count(paper_id) from paper_roles were user_id = %id_of_testuser
#   in order to determine the number of papers that should be shown on the dashboard

# connect to postgres, select title from paper, role from roles (join paper_roles where role_id...) join paper_roles
#   where user_id has role for paper.




  # def click_on_existing_manuscript_link(self, title):
  #   """Click on a link given a title"""
  #   first_matching_manuscript_link = self._get((By.LINK_TEXT,title))
  #   first_matching_manuscript_link.click()
  #   return self
  #
  # def click_on_existing_manuscript_link_partial_title(self, partial_title):
  #   """Click on existing manuscript link using partial title"""
  #   first_article_link = self._driver.find_element_by_partial_link_text(partial_title)
  #   first_article_link.click()
  #   return first_article_link.text
  #
  # def verify_editor_invites(self):
  #   editorInvitation = '1'
  #   print ('Starting validation of editor invitation count...')
  #   actualText = self._get(self._dashboard_title).text
  #   actualInvitationText = (re.search(r'\d+',actualText).group())
  #   self._validate_individual_text(actualInvitationText, editorInvitation)
  #
  # def verify_editor_invites_at_home(self):
  #   editorInvitation = 'Hi, Hendrik W.. You have 1 manuscript.'
  #   print ('Starting validation of editor invitation count in homepage...')
  #   actualText = self._get(self._check_for_one_invite_home).text
  #   self._validate_individual_text(actualText, editorInvitation)
  #
  # def verify_editor_no_invites_at_home(self):
  #   editorInvitation = 'Hi, Hendrik W.. You have no manuscripts.'
  #   print ('Starting validating editor has no invitation in homepage...')
  #   actualText = self._get(self._check_for_no_invites_home).text
  #   self._validate_individual_text(actualText, editorInvitation)
  #
  # def verify_error_assertion_failed_at_home(self):
  #   errorAssertFail = 'Error: Assertion Failed: calling set on destroyed object'
  #   print ('Starting validating error assertion failed at homepage...')
  #   actualText = self._get(self._check_error_assertion_failed).text
  #   self._validate_individual_text(actualText, errorAssertFail)
  #
  # def click_view_invitations_button(self):
  #   """Click on invitation button"""
  #   self._get(self._click_view_invitations_button).click()
  #   return self
  #
  # def click_yes_to_invitations(self):
  #   """Click yes button"""
  #   self._get(self._click_yes_to_invitations_button).click()
  #   return self
  #
  # def click_no_to_invitations(self):
  #   """Click no button"""
  #   self._get(self._click_no_to_invitations_button).click()
  #   return self

  # def _validate_individual_text(self, actualText, expectedText):
  #   """Validate text"""
  #   print ('Verifying text "%s":' % actualText,)
  #   assert actualText == expectedText
  #   print ('PRESENT',)
