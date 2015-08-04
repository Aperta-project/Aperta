#!/usr/bin/env python2

from selenium.webdriver.common.by import By
from Base.PlosPage import PlosPage

__author__ = 'fcabrales'

class WorkflowPage(PlosPage):
  """
  Model workflow page
  """
  def __init__(self, driver):
    super(WorkflowPage, self).__init__(driver, '/')

    #Locators - Instance members
    self._click_editor_assignment_button = (By.XPATH, './/div[2]/div[2]/div/div[4]/div')
    # Reviewer Report button name = Reviewer Recommendation in the card's title
    self._reviewer_agreement_button = (By.XPATH, 
      "//div[@class='column-content']/div/div//div[contains(., '[A] Reviewer Agreement')]")
    self._reviewer_recommendation_button = (By.XPATH, 
      "//div[@class='column-content']/div/div//div[contains(., '[A] Reviewer Report')]")
    self._completed_review_button = (By.XPATH, 
      "//div[@class='column-content']/div/div//div[contains(., '[A] Completed Review')]")    
    self._assess_button = (By.XPATH, "//div[@class='column-content']/div/div//div[contains(., '[A] Reviewer Report')]")
    self._editorial_decision_button = (By.XPATH, "//div[@class='column-content']/div/div//div[contains(., '[A] Editorial Decision')]")
    self._left_nav = (By.CSS_SELECTOR, 'div.navigation-toggle')
    self._hamburger_icon = (By.XPATH, 
      "//div[@class='navigation-toggle']/*[local-name() = 'svg']/*[local-name() = 'path']")
    self._left_nav_menu = (By.XPATH, ".//div/div/div[@class='navigation']")
    self._navigation_close = (By.XPATH, ".//div[@class='navigation']/div/span[@class='navigation-close']")
    self._navigation_title = (By.XPATH, ".//div[@class='navigation']/div")
    self._sign_out_link = (By.XPATH, './/div/div[1]/a')
    self._navigation_image = (By.XPATH, ".//div[@class='navigation']/div[2]/a")
    self._navigation_name = (By.XPATH, ".//div[@class='navigation']/div[2]/a/span")
    self._navigation_menu_dashboard = (By.XPATH, ".//div[@class='navigation']/div[3]/a")
    self._navigation_menu_flow_manager = (By.XPATH, ".//div[@class='navigation']/div[4]/a")
    self._navigation_menu_paper_tracker = (By.XPATH, ".//div[@class='navigation']/div[5]/a")
    self._navigation_menu_admin = (By.XPATH, ".//div[@class='navigation']/div[6]/a")
    self._navigation_menu_signout = (By.XPATH, ".//div[@class='navigation']/div[7]/a")
    self._navigation_menu_line = (By.XPATH, ".//div[@class='navigation']/hr")
    self._navigation_menu_feedback_link = (By.XPATH, ".//div[@class='navigation']/div[8]/a")
    self._editable_label = (By.XPATH, ".//div[@class='control-bar-inner-wrapper']/ul[2]/li/label")
    self._editable_checkbox = (By.XPATH, 
      ".//div[@class='control-bar-inner-wrapper']/ul[2]/li/label/input")
    self._recent_activity_icon = (By.XPATH, 
      ".//div[@class='control-bar-inner-wrapper']/ul[2]/li[2]/div/div/*[local-name() = 'svg']")
    self._recent_activity_text = (By.XPATH, 
      ".//div[@class='control-bar-inner-wrapper']/ul[2]/li[2]/div/div[2]")
    self._discussions_icon = (By.XPATH, 
      ".//div[@class='control-bar-inner-wrapper']/ul[2]/li[3]/a/div/span[contains(@class, 'fa-comment')]")
    self._discussions_text = (By.XPATH, 
      ".//div[@class='control-bar-inner-wrapper']/ul[2]/li[3]/a")
    self._manuscript_icon = (By.XPATH, 
      ".//div[@class='control-bar-inner-wrapper']/ul[2]/li[4]/div/div/*[local-name() = 'svg']")
    self._discussions_text = (By.XPATH, 
      ".//div[@class='control-bar-inner-wrapper']/ul[2]/li[4]/div/div[2]")
    

  #POM Actions

  def validate_initial_page_elements_styles(self):
    """ """
    # Validate menu elements (title and icon)
    hamburger_icon = self._get(self._hamburger_icon)
    assert hamburger_icon.get_attribute('d') == ('M4,10h24c1.104,0,2-0.896,2-2s-0.896-2-2-2H4C2.896,6,2,6.896,2,8S2.896,10,4,10z '
                'M28,14H4c-1.104,0-2,0.896-2,2  s0.896,2,2,2h24c1.104,0,2-0.896,2-2S29.104,14,28'
                ',14z M28,22H4c-1.104,0-2,0.896-2,2s0.896,2,2,2h24c1.104,0,2-0.896,2-2  S29.104,'
                '22,28,22z')
    left_nav = self._get(self._left_nav)
    assert left_nav.text == 'Tahi'
    assert left_nav.value_of_css_property('color') == '#39a329'
    assert 'Cabin' in left_nav.value_of_css_property('font-family')
    assert left_nav.value_of_css_property('font-size') == '24px'
    assert left_nav.value_of_css_property('font-weight') == '700'
    assert left_nav.value_of_css_property('text-transform') == 'uppercase'
    left_nav_menu = self._get(self._left_nav_menu)
    assert left_nav_menu
    # check for close
    left_nav_close_icon = self._get(self._navigation_close)
    assert left_nav_close_icon    
    # check for title
    left_nav_title= self._get(self._navigation_title)
    assert left_nav_title.text == 'Tahi'
    navigation_image = self._get(self._navigation_image)
    assert navigation_image
    assert navigation_image.value_of_css_property('width') == '32px'
    assert navigation_image.value_of_css_property('height') == '32px'
    assert navigation_image.value_of_css_property('border-radius') == '4px'
    navigation_name = self._get(self._navigation_name)
    assert navigation_name
    assert navigation_name.value_of_css_property('text-transform') == 'capitalize'
    self.assertEqual(navigation_name.value_of_css_property('font-size'), '15px')
    self.assertEqual(navigation_name.value_of_css_property('color'), '#fff')
    self.assertIn('Cabin', navigation_image.value_of_css_property('font-family'))
    # 
    editable = self._get(self._editable_label)
    self.assertEqual(editable.text, 'Editable')
    self.assertEqual(editable.value_of_css_property('font-size'), '10px')
    self.assertEqual(editable.value_of_css_property('color'), 'rgb(57, 163, 41)')
    self.assertEqual(editable.value_of_css_property('font-weight'), '700')
    self.assertIn('Cabin', editable.value_of_css_property('font-family'))
    self.assertEqual(editable.value_of_css_property('text-transform'), 'uppercase')
    self.assertEqual(editable.value_of_css_property('line-height'), '20px')
    self.assertEqual(editable.value_of_css_property('text-align'), 'center')
    editable_checkbox = self._get(self._editable_checkbox)
    self.assertEqual(editable_checkbox.get_attribute('type'), 'checkbox')
    self.assertEqual(editable_checkbox.value_of_css_property('color'), 'rgb(60, 60, 60)')
    self.assertEqual(editable_checkbox.value_of_css_property('font-size'), '10px')
    self.assertEqual(editable_checkbox.value_of_css_property('font-weight'), '700')

    recent_activity_icon = self._get(self._recent_activity_icon)
    self.assertEqual(recent_activity_icon.get_attribute('d'),
               ('M-171.3,403.5c-2.4,0-4.5,1.4-5.5,3.5c0,0-0.1,0-0.1,0h-9.9l-6.5-17.2  '
                'c-0.5-1.2-1.7-2-3-1.9c-1.3,0.1-2.4,1-2.7,2.3l-4.3,18.9l-4-43.4c-0.1-1'
                '.4-1.2-2.5-2.7-2.7c-1.4-0.1-2.7,0.7-3.2,2.1l-12.5,41.6  h-16.2c-1.6,0'
                '-3,1.3-3,3c0,1.6,1.3,3,3,3h18.4c1.3,0,2.5-0.9,2.9-2.1l8.7-29l4.3,46.8'
                'c0.1,1.5,1.3,2.6,2.8,2.7c0.1,0,0.1,0,0.2,0  c1.4,0,2.6-1,2.9-2.3l6.2-'
                '27.6l3.7,9.8c0.4,1.2,1.5,1.9,2.8,1.9h11.9c0.2,0,0.3-0.1,0.5-0.1c1.1,1'
                '.7,3,2.8,5.1,2.8  c3.4,0,6.1-2.7,6.1-6.1C-165.3,406.2-168,403.5-171.3,403.5z'))
    self.assertEqual(recent_activity_icon.value_of_css_property('color'), 'rgb(57, 163, 41)')
    recent_activity_text = self._get(self._recent_activity_text)
    self.asserTrue(recent_activity_text)
    self.assertEqual(recent_activity_text.text, 'Recent Activity')
    self.assertEqual(recent_activity_text.value_of_css_property('font-size'), '10px')
    self.assertEqual(recent_activity_text.value_of_css_property('color'), 'rgb(57, 163, 41)')
    self.assertEqual(recent_activity_text.value_of_css_property('font-weight'), '700')
    self.assertIn('Cabin', recent_activity_text.value_of_css_property('font-family'))
    self.assertEqual(recent_activity_text.value_of_css_property('text-transform'), 'uppercase')
    self.assertEqual(recent_activity_text.value_of_css_property('line-height'), '20px')
    self.assertEqual(recent_activity_text.value_of_css_property('text-align'), 'center')
    discussions_icon = self._get(self._discussions_icon)
    self.asserTrue(discussions_icon)
    self.assertEqual(discussions_icon.value_of_css_property('font-family'), 'FontAwesome')
    self.assertEqual(discussions_icon.value_of_css_property('font-size'), '16px')
    self.assertEqual(discussions_icon.value_of_css_property('color'), 'rgb(57, 163, 41)')
    self.assertEqual(discussions_icon.value_of_css_property('font-weight'), '400')
    self.assertEqual(discussions_icon.value_of_css_property('text-transform'), 'uppercase')
    self.assertEqual(discussions_icon.value_of_css_property('font-style'), 'normal')

    discussions_text = self._get(self._discussions_text)
    self.asserTrue(discussions_text)
    self.assertEqual(discussions_text.text, 'Discussions')






    assert welcome_msg.text == 'Welcome to Tahi'
    assert 'helvetica' in welcome_msg.value_of_css_property('font-family')

  #def is_navigation_menu_visible(self):
  #  """ """
  #  self._get(self._click_editor_assignment_button)

  def click_editor_assignment_button(self):
    """Click editor assignment button"""
    self._get(self._click_editor_assignment_button).click()
    return self

  def get_assess_button(self):
    return self._get(self._assess_button)

  def click_reviewer_agreement_button(self):
    """Click reviewer agreement button"""
    self._get(self._reviewer_agreement_button).click()
    return self

  def click_completed_review_button(self):
    """Click completed review button"""
    self._get(self._completed_review_button).click()
    return self

  def click_reviewer_recommendation_button(self):
    """Click reviewer recommendation button"""
    self._get(self._reviewer_recommendation_button).click()
    return self

  def click_editorial_decision_button(self):
    """Click editorial decision button"""
    self._get(self._editorial_decision_button).click()
    return self

  def click_assess_button(self):
    """Click assess button"""
    self._get(self._assess_button).click()
    return self

  def click_left_nav(self):
    """Click left navigation"""
    self._get(self._left_nav).click()
    return self

  def click_sign_out_link(self):
    """Click sign out link"""
    self._get(self._sign_out_link).click()
    return self
