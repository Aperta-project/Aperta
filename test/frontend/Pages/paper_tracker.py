#!/usr/bin/env python2

from selenium.webdriver.common.by import By
from authenticated_page import AuthenticatedPage

__author__ = 'jgray@plos.org'


class PaperTrackerPage(AuthenticatedPage):
  """
  Model an aperta paper tracker page
  """
  def __init__(self, driver, url_suffix='/'):
    super(PaperTrackerPage, self).__init__(driver, url_suffix)

    # Locators - Instance members
    self._paper_tracker_title = (By.CLASS_NAME, 'paper-tracker-message')
    self._paper_tracker_subhead = (By.CLASS_NAME, 'paper-tracker-paper-count')
    self._paper_tracker_table = (By.CLASS_NAME, 'paper-tracker-table')
    self._paper_tracker_table_title_th = (By.XPATH, '//th[2]')
    self._paper_tracker_table_paper_id_th = (By.XPATH, '//th[3]')
    self._paper_tracker_table_submit_date_th = (By.XPATH, '//th[4]')
    self._paper_tracker_table_paper_type_th = (By.XPATH, '//th[5]')
    self._paper_tracker_table_members_th = (By.XPATH, '//th[6]')


  # POM Actions
  def validate_initial_page_elements_styles(self):
    title = self._get(self._paper_tracker_title)
    subhead = self._get(self._paper_tracker_subhead)
    table = self._get(self._paper_tracker_table)
    title_th = self._get(self._paper_tracker_table_title_th)
    papid_th = self._get(self._paper_tracker_table_paper_id_th)
    subdate_th = self._get(self._paper_tracker_table_submit_date_th)
    paptype_th = self._get(self._paper_tracker_table_paper_type_th)
    members_th = self._get(self._paper_tracker_table_members_th)

  def validate_nav_elements(self, permissions):
    elevated = ['jgray_flowmgr', 'jgray']
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
    if permissions == ('jgray_oa', 'jgray'):
      self._get(self._nav_admin_link)
