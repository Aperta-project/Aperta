#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
A class to be inherited from every page for ensuring style consistency across the application.

A note to maintainers: Please for Gopod's sake, please pay attention to the section headings in this
file and place any new definitions within the appropriate section headings.

Note also that there is a surfeit of application specific nomenclature here. We need to ensure that
  if you *extend* this nomenclature, that you do it only in the context of a shared understanding
  of the term by the Aperta team as a whole. There is a danger is using what you may think is a
  well-understood concept where you have not talked to other team members to ensure that is the
  common way the team references a thing: it leads to duplication under different terms.

  This file follows the named sections of the Style guide, current version 1.1 from:
  https://app.zeplin.io/project.html#pid=560d7bb83705520f4c7c0524&sid=58c2f1695592e9057db985c8
  These sections are in order:
    - Typography
    - Icons
    - Form Elements
    - Navigation
    - Layout
    - Colors
    - Text Elements
    - Cards
    - Tables
    - Components
"""

from Base.PlosPage import PlosPage

__author__ = 'jgray@plos.org'
# Variable definitions

# typefaces
APPLICATION_TYPEFACE = 'source-sans-pro'
MANUSCRIPT_TYPEFACE = 'lora'
# colors
APERTA_GREEN = 'rgba(57, 163, 41, 1)'
APERTA_GREEN_LIGHT = 'rgba(142, 203, 135, 1)'
APERTA_GREEN_DARK = 'rgba(15, 116, 0, 1)'
APERTA_BLUE = 'rgba(45, 133, 222, 1)'
APERTA_BLUE_LIGHT = 'rgba(215, 235, 254, 1)'
APERTA_BLUE_DARK = 'rgba(32, 94, 156, 1)'
APERTA_GREY_XLIGHT = 'rgba(245, 245, 245, 1)'
APERTA_GREY_LIGHT = 'rgba(213, 213, 213, 1)'
APERTA_GREY_DARK = 'rgba(135, 135, 135, 1)'
APERTA_BLACK = 'rgba(51, 51, 51, 1)'
APERTA_ERROR = 'rgba(206, 11, 36, 1)'
WHITE = 'rgba(255, 255, 255, 1)'
BLACK = 'rgba(0, 0, 0, 1)'
APERTA_FLASH_ERROR = 'rgba(122, 51, 78, 1)'
APERTA_FLASH_ERROR_BKGRND = 'rgba(230, 221, 210, 1)'
APERTA_FLASH_SUCCESS = APERTA_GREEN
APERTA_FLASH_SUCCESS_BKGRND = 'rgba(234, 253, 231, 1)'
APERTA_FLASH_INFO = 'rgba(146, 139, 113, 1)'
APERTA_FLASH_INFO_BKGRND = 'rgba(242, 242, 213, 1)'


class StyledPage(PlosPage):
  """
  Model the common styles of elements of the authenticated pages to enforce consistency
  """

  def __init__(self, driver, url_suffix='/'):
    super(StyledPage, self).__init__(driver, url_suffix)
  # ===================================================
  # Typography ========================================
  # Note typefaces are defined as global variables at the top of the file
  @staticmethod
  def validate_application_title_style(title):
    """
    Ensure consistency in rendering Titles across the application
    Examples where used: Card title in overlay view
    :param title: title to validate
    Updated for new style guide: https://app.zeplin.io/project.html
    """
    assert APPLICATION_TYPEFACE in title.value_of_css_property('font-family'), \
      title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '48px', title.value_of_css_property(
      'font-size')
    assert title.value_of_css_property('line-height') == '52px', title.value_of_css_property(
      'line-height')
    # font-weight is canonically specified as 'normal' whatever that means.
    assert title.value_of_css_property('font-weight') == '500', title.value_of_css_property(
      'font-weight')
    assert title.value_of_css_property('color') == APERTA_BLACK, title.value_of_css_property(
      'color')

  @staticmethod
  def validate_application_section_heading_style(title, admin=False):
    """
    Ensure consistency in rendering section headings across the application
    Examples where used: Card section name
    :param title: title to validate
    :param admin: a boolean indicating whether the title appears in the admin section and is thus
      blue
    """
    assert APPLICATION_TYPEFACE in title.value_of_css_property('font-family'), \
      title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '30px', title.value_of_css_property(
      'font-size')
    assert title.value_of_css_property('line-height') == '33px', title.value_of_css_property(
      'line-height')
    # font-weight is canonically specified as 'normal' whatever that means.
    assert title.value_of_css_property('font-weight') == '500', title.value_of_css_property(
      'font-weight')
    if admin:
      assert title.value_of_css_property('color') == APERTA_BLUE, title.value_of_css_property(
        'color')
    else:
      assert title.value_of_css_property('color') == APERTA_BLACK, title.value_of_css_property(
        'color')

  @staticmethod
  def validate_application_subheading_style(title):
    """
    Ensure consistency in rendering page and overlay main headings across the application
    Not used for the Manuscript Title!
    :param title: title to validate
    Updated for new style guide: https://app.zeplin.io/project.html
    """
    assert APPLICATION_TYPEFACE in title.value_of_css_property('font-family'), \
      title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '20px', title.value_of_css_property(
      'font-size')
    assert title.value_of_css_property('font-weight') == '400', title.value_of_css_property(
      'font-weight')
    # APERTA-9305
    # assert title.value_of_css_property('line-height') == '22px', title.value_of_css_property(
    # 'line-height')
    assert title.value_of_css_property('color') == APERTA_BLACK, title.value_of_css_property(
      'color')

  @staticmethod
  def validate_application_h2_style(title):
    """
    Ensure consistency in rendering page and overlay h2 section headings across the application
    :param title: title to validate
    """
    assert APPLICATION_TYPEFACE in title.value_of_css_property('font-family'), \
      title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '30px', title.value_of_css_property(
      'font-size')
    assert title.value_of_css_property('font-weight') == '500', title.value_of_css_property(
      'font-weight')
    assert title.value_of_css_property('line-height') == '33px', title.value_of_css_property(
      'line-height')
    # This color is not represented in the tahi palette
    assert title.value_of_css_property('color') == APERTA_BLACK, title.value_of_css_property(
      'color')

  @staticmethod
  def validate_application_h3_style(title):
    """
    Ensure consistency in rendering page and overlay h3 section headings across the application
    :param title: title to validate
    """
    assert APPLICATION_TYPEFACE in title.value_of_css_property('font-family'), \
      title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '24px', title.value_of_css_property(
      'font-size')
    assert title.value_of_css_property('font-weight') == '500', title.value_of_css_property(
      'font-weight')
    assert title.value_of_css_property('line-height') == '26.4px', title.value_of_css_property(
      'line-height')
    # This color is not represented in the tahi palette
    assert title.value_of_css_property('color') == APERTA_BLACK, title.value_of_css_property(
      'color')

  @staticmethod
  def validate_application_h4_style(title):
    """
    Ensure consistency in rendering page and overlay h4 section headings across the application
    :param title: title to validate
    """
    assert APPLICATION_TYPEFACE in title.value_of_css_property('font-family'), \
      title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '18px', title.value_of_css_property(
      'font-size')
    assert title.value_of_css_property('font-weight') == '500', title.value_of_css_property(
      'font-weight')
    assert title.value_of_css_property('line-height') == '18px', title.value_of_css_property(
      'line-height')
    # This color is not represented in the tahi palette
    assert title.value_of_css_property('color') == APERTA_BLACK, title.value_of_css_property(
      'color')

  @staticmethod
  def validate_manuscript_h1_style(title):
    """
    Ensure consistency in rendering page and overlay main headings within the manuscript
    :param title: title to validate
    """
    assert MANUSCRIPT_TYPEFACE in title.value_of_css_property('font-family'), \
      title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '36px', title.value_of_css_property(
      'font-size')
    assert title.value_of_css_property('font-weight') == '500', title.value_of_css_property(
      'font-weight')
    assert title.value_of_css_property('line-height') == '39.6px', title.value_of_css_property(
      'line-height')
    # This color is not represented in the tahi palette
    assert title.value_of_css_property('color') == APERTA_BLACK, title.value_of_css_property(
      'color')

  @staticmethod
  def validate_manuscript_h2_style(title):
    """
    Ensure consistency in rendering page and overlay h2 section headings within the manuscript
    :param title: Title to validate
    """
    assert MANUSCRIPT_TYPEFACE in title.value_of_css_property('font-family'), \
      title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '30px', title.value_of_css_property(
      'font-size')
    assert title.value_of_css_property('font-weight') == '500', title.value_of_css_property(
      'font-weight')
    assert title.value_of_css_property('line-height') == '33px', title.value_of_css_property(
      'line-height')
    # This color is not represented in the tahi palette
    assert title.value_of_css_property('color') == APERTA_BLACK, title.value_of_css_property(
      'color')

  @staticmethod
  def validate_manuscript_h3_style(title):
    """
    Ensure consistency in rendering page and overlay h3 section headings within the manuscript
    :param title: title to validate
    """
    assert MANUSCRIPT_TYPEFACE in title.value_of_css_property('font-family'), \
      title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '24px', title.value_of_css_property(
      'font-size')
    assert title.value_of_css_property('font-weight') == '500', title.value_of_css_property(
      'font-weight')
    assert title.value_of_css_property('line-height') == '26.4px', title.value_of_css_property(
      'line-height')
    # This color is not represented in the tahi palette
    assert title.value_of_css_property('color') == APERTA_BLACK, title.value_of_css_property(
      'color')

  @staticmethod
  def validate_manuscript_h4_style(title):
    """
    Ensure consistency in rendering page and overlay h4 section headings within the manuscript
    :param title: title to validate
    """
    assert MANUSCRIPT_TYPEFACE in title.value_of_css_property('font-family'), \
      title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '18px', title.value_of_css_property(
      'font-size')
    assert title.value_of_css_property('font-weight') == '500', title.value_of_css_property(
      'font-weight')
    assert title.value_of_css_property('line-height') == '19.8px', title.value_of_css_property(
      'line-height')
    # This color is not represented in the tahi palette
    assert title.value_of_css_property('color') == APERTA_BLACK, title.value_of_css_property(
      'color')

  # This seems out of bounds - this should conform to one of the above styles - report as a bug
  @staticmethod
  def validate_profile_title_style(title):
    """
    Ensure consistency in rendering page and overlay main headings across the application
    :param title: title to validate
    :return: Void Function
    """
    assert APPLICATION_TYPEFACE in title.value_of_css_property('font-family'), \
      title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '14px', title.value_of_css_property(
      'font-size')
    assert title.value_of_css_property('font-weight') == '500', title.value_of_css_property(
      'font-weight')
    assert title.value_of_css_property('line-height') == '15.4px', title.value_of_css_property(
      'line-height')
    # This color is not represented in the tahi palette
    assert title.value_of_css_property(
      'color') == 'rgba(153, 153, 153, 1)', title.value_of_css_property('color')



    # ===================================================
  # Icons =============================================

  # ===================================================
  # Form Elements =====================================

  # ===================================================
  # Navigation ========================================

  # ===================================================
  # Layout ============================================

  # ===================================================
  # Colors ============================================
  # Note Colors are defined as global variables at the top of the file

  # ===================================================
  # Text Elements =====================================

  # ===================================================
  # Cards =============================================

  # ===================================================
  # Tables ============================================

  # ===================================================
  # Components ========================================

  # Divider and Border Styles ===========================
  @staticmethod
  def validate_light_background_border(border):
    """
    This border style is used against the $color-light variants only
    :param border: border
    :return: Void function
    """
    # This color is not represented in the tahi palette
    assert border.value_of_css_property('color') == 'rgba(128, 128, 128, 1)', border.value_of_css_property('color')
    assert border.value_of_css_property('background-color') in (APERTA_GREEN_LIGHT, APERTA_BLUE_LIGHT, APERTA_GREY_LIGHT), \
        border.value_of_css_property('background-color')

  @staticmethod
  def validate_standard_border(border):
    """
    This border style is used against all but the light color variants.
    :param border: border
    :return: Void function
    """
    # This color is not represented in the tahi palette
    assert border.value_of_css_property('color') == APERTA_BLACK, border.value_of_css_property('color')

  # Heading Styles ===========================
  # This method is out of bounds and should not be here
  @staticmethod
  def validate_modal_title_style(title, font_size='14px', font_weight='400',
                                 line_height='20px', color=APERTA_BLACK):
    """
    Ensure consistency in rendering page and overlay main headings across the application
    :param title: title to validate
    :param font_size
    :param font_weight
    :param line_height
    :param color
    :return: None
    TODO: APERTA-7212
    """
    assert APPLICATION_TYPEFACE in title.value_of_css_property('font-family'), \
        '{0} not found in {1}'.format(APPLICATION_TYPEFACE,
                                      title.value_of_css_property('font-family'))
    assert title.value_of_css_property('font-size') == font_size, \
        '{0) is not equal to {1}'.format(title.value_of_css_property('font-size'), font_size)
    assert title.value_of_css_property('font-weight') == font_weight, \
        '{0) is not equal to {1}'.format(title.value_of_css_property('font-weight'), font_weight)
    assert title.value_of_css_property('line-height') == line_height, \
        '{0) is not equal to {1}'.format(title.value_of_css_property('line-height'), line_height)
    assert title.value_of_css_property('color') == color, \
        '{0) is not equal to {1}'.format(title.value_of_css_property('color'), color)

  @staticmethod
  def validate_field_title_style(title):
    """
    Ensure consistency in rendering field titles across the application
    :param title: title to validate
    :return: None
    """
    assert APPLICATION_TYPEFACE in title.value_of_css_property('font-family'), \
        title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '14px', \
        title.value_of_css_property('font-size')
    assert title.value_of_css_property('line-height') == '20px', \
        title.value_of_css_property('line-height')
    assert title.value_of_css_property('font-weight') == '400', \
        title.value_of_css_property('font-weight')
    assert title.value_of_css_property('color') == APERTA_GREY_DARK, \
        title.value_of_css_property('color')

  @staticmethod
  def validate_accordion_task_title(title):
    """
    Ensure consistency in rendering accordion headings across the application
    :param title: title to validate
    Updated for new style guide: https://app.zeplin.io/project.html
    """
    assert APPLICATION_TYPEFACE in title.value_of_css_property('font-family'), \
        title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '18px', title.value_of_css_property('font-size')
    assert title.value_of_css_property('line-height') == '40px', title.value_of_css_property('line-height')
    assert title.value_of_css_property('color') == APERTA_BLACK, title.value_of_css_property('color')

  @staticmethod
  def validate_action_status_text(message):
    """In some places in the app, we give a status message in a large green font"""
    assert APPLICATION_TYPEFACE in message.value_of_css_property('font-family'), \
      message.value_of_css_property('font-family')
    assert message.value_of_css_property('font-size') == '16px', message.value_of_css_property(
      'font-size')
    assert message.value_of_css_property('line-height') == '22.85px', message.value_of_css_property(
      'line-height')
    assert message.value_of_css_property('color') == APERTA_GREEN, message.value_of_css_property(
      'color')

  # Ordinary Text Styles ============================
  @staticmethod
  def validate_application_ptext(paragraph):
    """
    Ensure consistency in rendering application ordinary text and paragraph text across the application
    :param paragraph: paragraph to validate
    :return: Void Function
    """
    assert APPLICATION_TYPEFACE in paragraph.value_of_css_property('font-family'), \
        paragraph.value_of_css_property('font-family')
    assert paragraph.value_of_css_property('font-size') == '14px', paragraph.value_of_css_property('font-size')
    assert paragraph.value_of_css_property('font-weight') == '400', paragraph.value_of_css_property('font-weight')
    assert paragraph.value_of_css_property('line-height') == '20px', paragraph.value_of_css_property('line-height')
    # This color is not represented in the tahi palette
    assert paragraph.value_of_css_property('color') == APERTA_BLACK, paragraph.value_of_css_property('color')

  @staticmethod
  def validate_manuscript_ptext(paragraph):
    """
    Ensure consistency in rendering manuscript ordinary text and paragraph text across the application
    :param paragraph: paragraph to validate
    :return: Void Function
    """
    assert MANUSCRIPT_TYPEFACE in paragraph.value_of_css_property('font-family'), \
        paragraph.value_of_css_property('font-family')
    assert paragraph.value_of_css_property('font-size') == '14px', paragraph.value_of_css_property('font-size')
    assert paragraph.value_of_css_property('font-weight') == '400', paragraph.value_of_css_property('font-weight')
    assert paragraph.value_of_css_property('line-height') == '20px', paragraph.value_of_css_property('line-height')
    # This color is not represented in the tahi palette
    assert paragraph.value_of_css_property('color') == APERTA_BLACK, paragraph.value_of_css_property('color')

  # Link Styles ==============================
  @staticmethod
  def validate_default_link_style(link):
    """
    Ensure consistency in rendering links across the application
    :param link: link to validate
    """
    assert APPLICATION_TYPEFACE in link.value_of_css_property('font-family'), link.value_of_css_property('font-family')
    assert link.value_of_css_property('font-size') == '14px', link.value_of_css_property('font-size')
    assert link.value_of_css_property('line-height') == '20px', link.value_of_css_property('line-height')
    assert link.value_of_css_property('background-color') == 'transparent', \
        link.value_of_css_property('background-color')
    assert link.value_of_css_property('color') == APERTA_GREEN, link.value_of_css_property('color')
    assert link.value_of_css_property('font-weight') == '400', link.value_of_css_property('font-weight')

  @staticmethod
  def validate_mention_style(element):
    """
    Validate style of the mention
    """
    assert APPLICATION_TYPEFACE in element.value_of_css_property('font-family'), \
        element.value_of_css_property('font-family')
    assert element.value_of_css_property('color') == APERTA_GREEN, element.value_of_css_property('color')
    assert element.value_of_css_property('font-size') == '14px', element.value_of_css_property('font-size')
    assert element.value_of_css_property('line-height') == '18.2px', element.value_of_css_property('line-height')
    assert element.value_of_css_property('font-weight') == '400', element.value_of_css_property('font-weight')

  @staticmethod
  def validate_profile_link_style(link):
    """
    Links valid in profile page
    :param link: link to validate
    """
    assert APPLICATION_TYPEFACE in link.value_of_css_property('font-family'), link.value_of_css_property('font-family')
    assert link.value_of_css_property('font-size') == '14px', link.value_of_css_property('font-size')
    assert link.value_of_css_property('line-height') == '20px', link.value_of_css_property('line-height')
    assert link.value_of_css_property('background-color') == 'transparent', \
        link.value_of_css_property('background-color')
    assert link.value_of_css_property('color') == APERTA_GREEN, link.value_of_css_property('color')
    assert link.value_of_css_property('font-weight') == '700', link.value_of_css_property('font-weight')

  @staticmethod
  def validate_default_link_hover_style(link):
    """
    Ensure consistency in rendering link hover across the application
    :param link: link to validate
    """
    assert APPLICATION_TYPEFACE in link.value_of_css_property('font-family'), link.value_of_css_property('font-family')
    assert link.value_of_css_property('font-size') == '14px', link.value_of_css_property('font-size')
    assert link.value_of_css_property('line-height') == '20px', link.value_of_css_property('line-height')
    assert link.value_of_css_property('background-color') == 'transparent', \
        link.value_of_css_property('background-color')
    assert link.value_of_css_property('color') == APERTA_GREEN, link.value_of_css_property('color')
    assert link.value_of_css_property('font-weight') == '400', link.value_of_css_property('font-weight')
    assert link.value_of_css_property('text-decoration') == 'underline', link.value_of_css_property('text-decoration')

  @staticmethod
  def validate_admin_link_style(link):
    """
    Ensure consistency in rendering links across the application
    :param link: link to validate
    """
    assert APPLICATION_TYPEFACE in link.value_of_css_property('font-family'), link.value_of_css_property('font-family')
    assert link.value_of_css_property('font-size') == '14px', link.value_of_css_property('font-size')
    assert link.value_of_css_property('line-height') == '20px', link.value_of_css_property('line-height')
    assert link.value_of_css_property('background-color') == 'transparent', \
        link.value_of_css_property('background-color')
    assert link.value_of_css_property('color') == APERTA_BLUE, link.value_of_css_property('color')
    assert link.value_of_css_property('font-weight') == '400', link.value_of_css_property('font-weight')

  @staticmethod
  def validate_admin_link_hover_style(link):
    """
    Ensure consistency in rendering link hover across the application
    :param link: link to validate
    """
    assert APPLICATION_TYPEFACE in link.value_of_css_property('font-family'), link.value_of_css_property('font-family')
    assert link.value_of_css_property('font-size') == '14px', link.value_of_css_property('font-size')
    assert link.value_of_css_property('line-height') == '20px', link.value_of_css_property('line-height')
    assert link.value_of_css_property('background-color') == 'transparent', \
        link.value_of_css_property('background-color')
    assert link.value_of_css_property('color') == APERTA_BLUE, link.value_of_css_property('color')
    assert link.value_of_css_property('font-weight') == '400', link.value_of_css_property('font-weight')
    assert link.value_of_css_property('text-decoration') == 'underline', link.value_of_css_property('text-decoration')

  @staticmethod
  def validate_disabled_link_style(link):
    """
    Ensure consistency in rendering links across the application
    :param link: link to validate
    """
    assert APPLICATION_TYPEFACE in link.value_of_css_property('font-family'), link.value_of_css_property('font-family')
    assert link.value_of_css_property('font-size') == '14px', link.value_of_css_property('font-size')
    assert link.value_of_css_property('line-height') == '20px', link.value_of_css_property('line-height')
    assert link.value_of_css_property('background-color') == 'transparent', \
        link.value_of_css_property('background-color')
    # This color is not represented in the tahi palette
    assert link.value_of_css_property('color') == APERTA_BLACK, link.value_of_css_property('color')
    assert link.value_of_css_property('font-weight') == '400', link.value_of_css_property('font-weight')

  # Confirmation Styles =====================
  @staticmethod
  def validate_cancel_confirmation_style(cancel):
    """
    Ensure consistency in rendering cancel link in confirmation across confirmation
    :param cancel: Cancel element
    """
    assert APPLICATION_TYPEFACE in cancel.value_of_css_property('font-family'), \
        cancel.value_of_css_property('font-family')
    assert cancel.value_of_css_property('font-size') == '14px', \
        cancel.value_of_css_property('font-size')
    assert cancel.value_of_css_property('font-weight') == '400', \
        cancel.value_of_css_property('font-weight')
    assert cancel.value_of_css_property('line-height') == '20px', \
        cancel.value_of_css_property('line-height')
    assert cancel.value_of_css_property('color') == WHITE, \
        cancel.value_of_css_property('color')
    assert cancel.value_of_css_property('text-align') == 'center', \
        cancel.value_of_css_property('text-align')

  @staticmethod
  def validate_delete_confirmation_style(delete):
    """
    Ensure consistency in rendering cancel link across confirmation
    :param cancel: Cancel element
    """
    assert APPLICATION_TYPEFACE in delete.value_of_css_property('font-family'), \
        delete.value_of_css_property('font-family')
    assert delete.value_of_css_property('font-size') == '14px', \
        delete.value_of_css_property('font-size')
    assert delete.value_of_css_property('font-weight') == '400', \
        delete.value_of_css_property('font-weight')
    assert delete.value_of_css_property('line-height') == '20px', \
        delete.value_of_css_property('line-height')
    assert delete.value_of_css_property('color') == APERTA_GREEN, \
        delete.value_of_css_property('color')
    assert delete.value_of_css_property('text-align') == 'center', \
        delete.value_of_css_property('text-align')
    assert delete.value_of_css_property('background-color') == WHITE, \
        delete.value_of_css_property('vertical-align')

  #  List Styles ==============================
  @staticmethod
  def validate_application_list_style(olul):
    """
    Ensure consistency in list presentation across the application
    :param olul: ol or ul
    :return: Void function
    """
    assert APPLICATION_TYPEFACE in olul.value_of_css_property('font-family'), \
        olul.value_of_css_property('font-family')
    assert olul.value_of_css_property('font-size') == '19.6px', \
        olul.value_of_css_property('font-size')
    assert olul.value_of_css_property('line-height') == '23.5167px', \
        olul.value_of_css_property('line-height')
    # This color is not represented in the tahi palette
    assert olul.value_of_css_property('color') == APERTA_BLACK, olul.value_of_css_property('color')

  # Button Styles ============================
  @staticmethod
  def validate_primary_big_green_button_style(button):
    """
    Ensure consistency in rendering page and overlay large green-backed, WHITE text buttons across the application
    :param button: button to validate
    """
    assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == WHITE, button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == APERTA_GREEN, \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('text-transform') == 'uppercase', button.value_of_css_property('text-transform')
    assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '12px', button.value_of_css_property('padding-right')

  @staticmethod
  def delete_forever_btn_style_validation(button):
    """
    Ensure consistency in rendering page and overlay large slide-in green-backed, WHITE text
    buttons across the application. This style is not in the styleguide: APERTA-8504
    :param button: button to validate
    :return: None
    """
    assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == WHITE, button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == APERTA_GREEN, \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('text-transform') == 'uppercase', button.value_of_css_property('text-transform')
    assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '12px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_secondary_big_green_button_style(button):
    """
    Ensure consistency in rendering page and overlay big WHITE-backed, green text buttons across
      the application
    :param button: button to validate
    """
    assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', \
        button.value_of_css_property('font-size')
    # APERTA-6498
    # assert button.value_of_css_property('line-height') == '18px', \
    #     button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == APERTA_GREEN, \
        button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == WHITE, \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('vertical-align') == 'middle', \
        button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('text-transform') == 'uppercase', \
        button.value_of_css_property('text-transform')
    # APERTA-6498
    # assert button.value_of_css_property('padding-top') == '8px', \
    #     button.value_of_css_property('padding-top')
    # assert button.value_of_css_property('padding-bottom') == '8px', \
    #     button.value_of_css_property('padding-bottom')
    # assert button.value_of_css_property('padding-left') == '14px', \
    #     button.value_of_css_property('padding-left')
    # assert button.value_of_css_property('padding-right') == '14px', \
    #     button.value_of_css_property('padding-right')

  @staticmethod
  def validate_link_big_green_button_style(button):
    """
    Ensure consistency in rendering page and overlay transparent-backed, green text link-buttons across the application
    :param button: button to validate
    """
    assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == APERTA_GREEN, button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == 'transparent', \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property('text-align')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '12px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_primary_small_green_button_style(button):
    """
    Ensure consistency in rendering page and overlay small green-backed, WHITE text buttons across the application
    :param button: button to validate
    """
    assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == WHITE, button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == APERTA_GREEN, \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property('text-align')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('text-transform') == 'uppercase', button.value_of_css_property('text-transform')
    assert button.value_of_css_property('padding-top') == '1px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '1px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '5px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '5px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_secondary_small_green_button_style(button):
    """
    Ensure consistency in rendering page and overlay small WHITE-backed, green text buttons across the application
    :param button: button to validate
    """
    assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('color') == APERTA_GREEN, button.value_of_css_property('color')
    assert button.value_of_css_property('text-transform') == 'uppercase', button.value_of_css_property('text-transform')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property('text-align')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('background-color') == WHITE, \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('padding-top') == '1px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-right') == '5px', button.value_of_css_property('padding-right')
    assert button.value_of_css_property('padding-bottom') == '1px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '5px', button.value_of_css_property('padding-left')

  @staticmethod
  def validate_secondary_small_green_button_task_style(button):
    """
    Ensure consistency in rendering page and overlay small WHITE-backed, green text validations buttons
    across the application
    :param button: button to validate
    """
    assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('color') == APERTA_GREEN, button.value_of_css_property('color')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property('text-align')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('background-color') == WHITE, \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-right') == '12px', button.value_of_css_property('padding-right')
    assert button.value_of_css_property('padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property('padding-left')

  @staticmethod
  def validate_link_small_green_button_style(button):
    """
    Ensure consistency in rendering page and overlay transparent-backed, green text link-buttons across the application
    :param button: button to validate
    """
    assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == APERTA_GREEN, button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == 'transparent', \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property('text-align')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('padding-top') == '1px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '5px'
    assert button.value_of_css_property('padding-left') == '1px'
    assert button.value_of_css_property('padding-right') == '5px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_primary_big_disabled_button_style(button):
    """
    Ensure consistency in rendering page and overlay large grey-backed, lighter grey text disabled buttons across the
    application
    :param button: button to validate
    """
    assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == APERTA_GREY_LIGHT, button.value_of_css_property('color')
    # This color is not represented in the tahi palette
    assert button.value_of_css_property('background-color') == 'rgba(238, 238, 238, 1)', \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('text-transform') == 'uppercase', button.value_of_css_property('text-transform')
    assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '12px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_secondary_big_disabled_button_style(button):
    """
    Ensure consistency in rendering page and overlay large WHITE-backed, grey text disabled buttons across the
    application
    :param button: button to validate
    """
    assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == APERTA_GREY_LIGHT, button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == WHITE, \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('text-transform') == 'uppercase', button.value_of_css_property('text-transform')
    assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '12px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_link_big_disabled_button_style(button):
    """
    Ensure consistency in rendering page and overlay large transparent-backed, grey text disabled buttons across the
    application
    :param button: button to validate
    """
    assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == APERTA_GREY_LIGHT, button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == 'transparent', \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property('text-align')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '12px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_green_on_green_button_style(button):
    """
    Ensure consistency in rendering page and overlay light green-backed, dark green text buttons across the application.
    These buttons should be used against a standard APERTA_GREEN background
    :param button: button to validate
    """
    assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == APERTA_GREEN_DARK, button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == APERTA_GREEN_LIGHT, \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('text-transform') == 'uppercase', button.value_of_css_property('text-transform')
    assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '12px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_primary_big_grey_button_style(button):
    """
    Ensure consistency in rendering page and overlay large grey-backed, WHITE text buttons across the application
    TODO: Find out what the use case is for this design as it seems duplicative with the defined disabled buttons
    :param button: button to validate
    """
    assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == WHITE, button.value_of_css_property('color')
    # This color is not represented in the tahi palette
    assert button.value_of_css_property('background-color') == 'rgba(119, 119, 119, 1)', \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('text-transform') == 'uppercase', button.value_of_css_property('text-transform')
    assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '12px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_secondary_big_grey_button_style(button):
    """
    Ensure consistency in rendering page and overlay large WHITE-backed, grey text buttons across the application
    TODO: Find out what the use case is for this design as it seems duplicative with the defined disabled buttons
    :param button: button to validate
    """
    assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    # This color is not represented in the tahi palette
    assert button.value_of_css_property('color') == 'rgba(119, 119, 119, 1)', button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == WHITE, \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('text-transform') == 'uppercase', button.value_of_css_property('text-transform')
    assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '12px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_link_big_grey_button_style(button):
    """
    Ensure consistency in rendering page and overlay large transparent-backed, grey text buttons across the application
    TODO: Find out what the use case is for this design as it seems duplicative with the defined disabled buttons
    :param button: button to validate
    """
    assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    # This color is not represented in the tahi palette
    assert button.value_of_css_property('color') == APERTA_GREY_DARK, button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == 'transparent', \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property('text-align')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '12px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_primary_small_grey_button_style(button):
    """
    Ensure consistency in rendering page and overlay small grey-backed, WHITE text buttons across the application
    TODO: Find out what the use case is for this design as it seems duplicative with the defined disabled buttons
    :param button: button to validate
    """
    assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == WHITE, button.value_of_css_property('color')
    # This color is not represented in the tahi palette
    assert button.value_of_css_property('background-color') == 'rgba(119, 119, 19, 1)', \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property('text-align')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('text-transform') == 'uppercase', button.value_of_css_property('text-transform')
    assert button.value_of_css_property('padding-top') == '1px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '1px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '5px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '5px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_secondary_small_grey_button_style(button):
    """
    Ensure consistency in rendering page and overlay small WHITE-backed, grey text buttons across the application
    TODO: Find out what the use case is for this design as it seems duplicative with the defined disabled buttons
    :param button: button to validate
    """
    assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    # This color is not represented in the tahi palette
    assert button.value_of_css_property('color') == 'rgba(119, 119, 119, 1)', button.value_of_css_property('color')
    assert button.value_of_css_property('text-transform') == 'uppercase', button.value_of_css_property('text-transform')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property('text-align')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('background-color') == WHITE, \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('padding-top') == '1px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-right') == '5px', button.value_of_css_property('padding-right')
    assert button.value_of_css_property('padding-bottom') == '1px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '5px', button.value_of_css_property('padding-left')

  @staticmethod
  def validate_link_small_grey_button_style(button):
    """
    Ensure consistency in rendering page and overlay small transparent-backed, grey text link-buttons across the
    application
    TODO: Find out what the use case is for this design as it seems duplicative with the defined disabled buttons
    :param button: button to validate
    """
    assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    # This color is not represented in the tahi palette
    assert button.value_of_css_property('color') == 'rgba(119, 119, 119, 1)', button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == 'transparent', \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property('text-align')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('padding-top') == '1px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-left') == '5px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-bottom') == '1px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-right') == '5px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_grey_on_grey_button_style(button):
    """
    Ensure consistency in rendering page and overlay light grey-backed, dark-grey text buttons across the application
    These should be used on a standard tahi_grey background only.
    :param button: button to validate
    """
    assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == APERTA_GREY_DARK, button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == APERTA_GREY_LIGHT, \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('text-transform') == 'uppercase', button.value_of_css_property('text-transform')
    assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '12px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_primary_big_blue_button_style(button):
    """
    Ensure consistency in rendering page and overlay large blue-backed, WHITE text buttons across the application
    :param button: button to validate
    """
    assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == WHITE, button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == APERTA_BLUE, \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('text-transform') == 'uppercase', button.value_of_css_property('text-transform')
    assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '12px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_secondary_big_blue_button_style(button):
    """
    Ensure consistency in rendering page and overlay large WHITE-backed, blue text buttons across the application
    :param button: button to validate
    """
    assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == APERTA_BLUE, button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == WHITE, \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('text-transform') == 'uppercase', button.value_of_css_property('text-transform')
    assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '12px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_link_big_blue_button_style(button):
    """
    Ensure consistency in rendering page and overlay large transparent-backed, blue text buttons across the application
    :param button: button to validate
    """
    assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == APERTA_BLUE, button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == 'transparent', \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property('text-align')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '12px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_primary_small_blue_button_style(button):
    """
    Ensure consistency in rendering page and overlay small blue-backed, WHITE text buttons across the application
    :param button: button to validate
    """
    assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == WHITE, button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == APERTA_BLUE, \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property('text-align')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('text-transform') == 'uppercase', button.value_of_css_property('text-transform')
    assert button.value_of_css_property('padding-top') == '1px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '1px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '5px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '5px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_secondary_small_blue_button_style(button):
    """
    Ensure consistency in rendering page and overlay small WHITE-backed, blue text buttons across the application
    :param button: button to validate
    """
    assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('color') == APERTA_BLUE, button.value_of_css_property('color')
    assert button.value_of_css_property('text-transform') == 'uppercase', button.value_of_css_property('text-transform')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property('text-align')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('background-color') == WHITE, \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('padding-top') == '1px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-right') == '5px', button.value_of_css_property('padding-right')
    assert button.value_of_css_property('padding-bottom') == '1px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '5px', button.value_of_css_property('padding-left')

  @staticmethod
  def validate_link_small_blue_button_style(button):
    """
    Ensure consistency in rendering page and overlay small transparent-backed, blue text link-buttons across the
    application
    :param button: button to validate
    """
    assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == APERTA_BLUE, button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == 'transparent', \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property('text-align')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('padding-top') == '1px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-left') == '5px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-bottom') == '1px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-right') == '5px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_blue_on_blue_button_style(button):
    """
    Ensure consistency in rendering page and overlay light blue-backed, dark-blue text buttons across the application
    These should only be used against a standard APERTA_BLUE background
    :param button: button to validate
    """
    assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == APERTA_BLUE, button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == WHITE, \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('text-transform') == 'uppercase', button.value_of_css_property('text-transform')
    assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '12px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_primary_error_button_style(button):
    """
    Ensure consistency in rendering page and overlay validation failed WHITE background buttons across the application
    :param button: button to validate
    """
    assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == APERTA_ERROR, button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == WHITE, \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property('text-align')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('text-transform') == 'uppercase', button.value_of_css_property('text-transform')
    assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '12px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_cancel_link_style(cancel):
    """
    Ensure consistency in rendering cancel link across confirmation
    :param cancel: Cancel element
    """
    assert APPLICATION_TYPEFACE in cancel.value_of_css_property('font-family'), \
        cancel.value_of_css_property('font-family')
    assert cancel.value_of_css_property('font-size') == '14px', \
        cancel.value_of_css_property('font-size')
    assert cancel.value_of_css_property('font-weight') == '400', \
        cancel.value_of_css_property('font-weight')
    assert cancel.value_of_css_property('line-height') == '20px', \
        cancel.value_of_css_property('line-height')
    assert cancel.value_of_css_property('color') == APERTA_GREEN, \
        cancel.value_of_css_property('color')
    assert cancel.value_of_css_property('text-align') == 'center', \
        cancel.value_of_css_property('text-align')

  # Form Styles ==============================
  @staticmethod
  def validate_input_field_style(field):
    """
    Ensure consistency in rendering page, card and overlay input fields across the application
    :param field: field to validate
    """
    assert APPLICATION_TYPEFACE in field.value_of_css_property('font-family')
    assert field.value_of_css_property('font-size') == '14px', \
        field.value_of_css_property('font-size')
    assert field.value_of_css_property('font-weight') == '400', \
        field.value_of_css_property('font-weight')
    assert field.value_of_css_property('color') == 'rgba(85, 85, 85, 1)', \
        field.value_of_css_property('color')
    assert field.value_of_css_property('line-height') == '20px', \
        field.value_of_css_property('line-height')

  @staticmethod
  def validate_input_field_inside_label_style(label):
    """
    Ensure consistency in rendering page, card and overlay internal input field labels across the
      application
    :param label: label to validate
    NOTE: Updated 20160722 as per style guide at:
    https://app.zeplin.io/project.html#pid=560d7bb83705520f4c7c0524&sid=56b239c60e93fc526ca02f8f
    """
    assert APPLICATION_TYPEFACE in label.value_of_css_property('font-family')
    assert label.value_of_css_property('font-size') == '14px', \
        label.value_of_css_property('font-size')
    assert label.value_of_css_property('font-weight') == '400', \
        label.value_of_css_property('font-weight')
    assert label.value_of_css_property('color') == APERTA_GREY_DARK, \
        label.value_of_css_property('color')
    assert label.value_of_css_property('line-height') == '25.7167px', \
        label.value_of_css_property('line-height')

  @staticmethod
  def validate_input_field_external_label_style(label):
    """
    Ensure consistency in the rendering of page, card and overlay external input field labels across
      the application
    :param label: label to validate
    NOTE: Not currently defined in the style guide at all - This definition is based on the
      implementation of the Invite AE card.
    """
    assert APPLICATION_TYPEFACE in label.value_of_css_property('font-family'), \
        label.value_of_css_property('font-family')
    assert label.value_of_css_property('font-size') == '18px', \
        label.value_of_css_property('font-size')
    assert label.value_of_css_property('font-weight') == '400', \
        label.value_of_css_property('font-weight')
    assert label.value_of_css_property('color') == APERTA_BLACK, \
        label.value_of_css_property('color')
    assert label.value_of_css_property('line-height') == '25.7167px', \
        label.value_of_css_property('line-height')

  @staticmethod
  def validate_input_field_placeholder_style(placeholder):
    """
    Ensure consistency in rendering page, card and overlay internal input field labels across the
      application
    :param placeholder: text to validate
    """
    assert APPLICATION_TYPEFACE in placeholder.value_of_css_property('font-family')
    assert placeholder.value_of_css_property('font-size') == '14px', \
        placeholder.value_of_css_property('font-size')
    assert placeholder.value_of_css_property('font-weight') == '400', \
        placeholder.value_of_css_property('font-weight')
    assert placeholder.value_of_css_property('color') == APERTA_GREY_DARK, \
        placeholder.value_of_css_property('color')
    assert placeholder.value_of_css_property('line-height') == '20px', \
        placeholder.value_of_css_property('line-height')

  @staticmethod
  def validate_single_select_dropdown_style(field):
    """
    Ensure consistency in rendering page, card and overlay single select drop down fields across
      the application
    :param field: field to validate
    """
    assert APPLICATION_TYPEFACE in field.value_of_css_property('font-family')
    assert field.value_of_css_property('font-size') == '14px', \
        field.value_of_css_property('font-size')
    assert field.value_of_css_property('font-weight') == '400', \
        field.value_of_css_property('font-weight')
    assert field.value_of_css_property('color') == APERTA_BLACK, \
        field.value_of_css_property('color')
    assert field.value_of_css_property('line-height') == '18px', \
        field.value_of_css_property('line-height')
    assert field.value_of_css_property('padding-top') == '6px', \
        field.value_of_css_property('padding-top')
    assert field.value_of_css_property('padding-bottom') == '6px', \
        field.value_of_css_property('padding-bottom')
    assert field.value_of_css_property('padding-left') == '11px', \
        field.value_of_css_property('padding-left')
    assert field.value_of_css_property('padding-right') == '12px',\
        field.value_of_css_property('padding-left')

  @staticmethod
  def validate_multi_select_dropdown_style(field):
    """
    Ensure consistency in rendering page, card and overlay multi-select drop down fields across the application
    :param field: field to validate
    """
    assert APPLICATION_TYPEFACE in field.value_of_css_property('font-family')
    assert field.value_of_css_property('font-size') == '14px', \
        field.value_of_css_property('font-size')
    # This color is not represented in the style guide
    assert field.value_of_css_property('color') == APERTA_BLACK, \
        field.value_of_css_property('color')
    assert field.value_of_css_property('line-height') == '20px', \
        field.value_of_css_property('line-height')
    assert field.value_of_css_property('text-overflow') == 'ellipsis', \
        field.value_of_css_property('text-overflow')
    assert field.value_of_css_property('margin-right') == '26px', \
        field.value_of_css_property('margin-right')

  @staticmethod
  def validate_textarea_style(field):
    """
    Ensure consistency in rendering page, card and overlay textarea fields across the application
    :param field: field to validate
    """
    assert APPLICATION_TYPEFACE in field.value_of_css_property('font-family')
    assert field.value_of_css_property('font-size') == '14px', \
        field.value_of_css_property('font-size')
    assert field.value_of_css_property('font-weight') == '400', \
        field.value_of_css_property('font-weight')
    assert field.value_of_css_property('font-style') == 'normal', \
        field.value_of_css_property('font-style')
    # This color is not represented in the style guide
    assert field.value_of_css_property('color') == 'rgba(85, 85, 85, 1)', \
        field.value_of_css_property('color')
    assert field.value_of_css_property('line-height') == '20px', \
        field.value_of_css_property('line-height')
    assert field.value_of_css_property('background-color') == WHITE, \
        field.value_of_css_property('background-color')
    assert field.value_of_css_property('padding-top') == '6px', \
        field.value_of_css_property('padding-top')
    assert field.value_of_css_property('padding-right') == '12px', \
        field.value_of_css_property('padding-right')
    assert field.value_of_css_property('padding-bottom') == '6px', \
        field.value_of_css_property('padding-bottom')
    assert field.value_of_css_property('padding-left') == '12px', \
        field.value_of_css_property('padding-left')

  @staticmethod
  def validate_radio_button(button):
    """
    Ensure consistency in rendering page, card and overlay radio buttons across the application
    :param button: button to validate
    """
    assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', \
        button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', \
        button.value_of_css_property('font-weight')
    assert button.value_of_css_property('font-style') == 'normal', \
        button.value_of_css_property('font-style')
    # This color is not represented in the style guide. APERTA-8904
    #assert button.value_of_css_property('color') == BLACK, button.value_of_css_property('color')
    assert button.value_of_css_property('line-height') == '18px', \
        button.value_of_css_property('line-height')
    assert button.value_of_css_property('margin-top') == '4px', \
        button.value_of_css_property('margin-top')

  @staticmethod
  def validate_radio_button_label(label):
    """
    Ensure consistency in rendering page, card and overlay radio button labels across the application
    :param label: label to validate
    """
    assert APPLICATION_TYPEFACE in label.value_of_css_property('font-family')
    assert label.value_of_css_property('font-size') == '14px', \
        label.value_of_css_property('font-size')
    assert label.value_of_css_property('font-weight') == '400', \
        label.value_of_css_property('font-weight')
    assert label.value_of_css_property('font-style') == 'normal', \
        label.value_of_css_property('font-style')
    # This color is not represented in the style guide
    assert label.value_of_css_property('color') == APERTA_BLACK, \
        label.value_of_css_property('color')
    assert label.value_of_css_property('line-height') == '20px', \
        label.value_of_css_property('line-height')


  @staticmethod
  def validate_checkbox(checkbox):
    """
    Ensure consistency in rendering page, card and overlay checkboxes across the application
    :param checkbox: checkbox to validate
    """
    assert APPLICATION_TYPEFACE in checkbox.value_of_css_property('font-family')
    assert checkbox.value_of_css_property('font-size') == '12px', \
        checkbox.value_of_css_property('font-size')
    assert checkbox.value_of_css_property('font-weight') == '400', \
        checkbox.value_of_css_property('font-weight')
    assert checkbox.value_of_css_property('font-style') == 'normal', \
        checkbox.value_of_css_property('font-style')
    assert checkbox.value_of_css_property('color') == APERTA_BLACK, \
        checkbox.value_of_css_property('color')
    assert checkbox.value_of_css_property('line-height') == '20px', \
        checkbox.value_of_css_property('line-height')

  @staticmethod
  def validate_checkbox_label(label):
    """
    Ensure consistency in rendering page, card and overlay checkbox labels across the application
    :param label: label to validate
    """
    assert APPLICATION_TYPEFACE in label.value_of_css_property('font-family')
    assert label.value_of_css_property('font-size') == '14px', \
        label.value_of_css_property('font-size')
    assert label.value_of_css_property('font-weight') == '400', \
        label.value_of_css_property('font-weight')
    assert label.value_of_css_property('color') == APERTA_BLACK, \
        label.value_of_css_property('color')
    assert label.value_of_css_property('line-height') == '20px', \
        label.value_of_css_property('line-height')

  # Navigation Styles ========================
  # There are currently no defined navigation styles in the style guide

  # Error Styles =============================
  @staticmethod
  def validate_flash_info_style(msg):
    """
    Ensure consistency in rendering informational alerts across the application
    :param msg: alert message to validate
    """
    assert APPLICATION_TYPEFACE in msg.value_of_css_property('font-family'), \
        msg.value_of_css_property('font-family')
    assert msg.value_of_css_property('font-size') == '14px', msg.value_of_css_property('font-size')
    # This color is not represented in the tahi palette
    assert msg.value_of_css_property('color') == APERTA_BLACK, msg.value_of_css_property('color')
    assert msg.value_of_css_property('line-height') == '20px', \
        msg.value_of_css_property('line-height')
    assert msg.value_of_css_property('text-align') == 'center', \
        msg.value_of_css_property('text-align')
    assert msg.value_of_css_property('position') == 'relative', \
        msg.value_of_css_property('position')
    assert msg.value_of_css_property('display') == 'inline-block', \
        msg.value_of_css_property('display')

  @staticmethod
  def validate_flash_error_style(msg):
    """
    Ensure consistency in rendering error alerts across the application
    :param msg: alert message to validate
    """
    assert APPLICATION_TYPEFACE in msg.value_of_css_property('font-family'), msg.value_of_css_property('font-family')
    # assert msg.value_of_css_property('font-size') == '14px', msg.value_of_css_property('font-size')
    # This color is not represented in the style guide as a color and is not the color of the actual implementation
    # assert msg.value_of_css_property('color') == APERTA_FLASH_ERROR, msg.value_of_css_property('color')
    # This color is not represented in the style guide
    # assert msg.value_of_css_property('background-color') == 'rgba(247, 239, 233, 1)', \
    #    msg.value_of_css_property('background-color')
    # assert msg.value_of_css_property('line-height') == '20px', msg.value_of_css_property('line-height')
    # assert msg.value_of_css_property('text-align') == 'center', msg.value_of_css_property('text-align')
    # assert msg.value_of_css_property('position') == 'relative', msg.value_of_css_property('position')
    # assert msg.value_of_css_property('display') == 'inline-block', msg.value_of_css_property('display')

  @staticmethod
  def validate_flash_success_style(msg):
    """
    Ensure consistency in rendering success alerts across the application
    :param msg: alert message to validate
    """
    assert APPLICATION_TYPEFACE in msg.value_of_css_property('font-family'), msg.value_of_css_property('font-family')
    assert msg.value_of_css_property('font-size') == '14px', msg.value_of_css_property('font-size')
    assert msg.value_of_css_property('color') == APERTA_GREEN, msg.value_of_css_property('color')
    # This color is not represented in the style guide
    assert msg.value_of_css_property('background-color') == APERTA_FLASH_SUCCESS_BKGRND, \
        msg.value_of_css_property('background-color')
    assert msg.value_of_css_property('line-height') == '20px', msg.value_of_css_property('line-height')
    assert msg.value_of_css_property('text-align') == 'center', msg.value_of_css_property('text-align')
    assert msg.value_of_css_property('position') == 'relative', msg.value_of_css_property('position')
    assert msg.value_of_css_property('display') == 'inline-block', msg.value_of_css_property('display')

  @staticmethod
  def validate_flash_warn_style(msg):
    """
    Ensure consistency in rendering warning alerts across the application
    :param msg: alert message to validate
    """
    assert APPLICATION_TYPEFACE in msg.value_of_css_property('font-family'), msg.value_of_css_property('font-family')
    assert msg.value_of_css_property('font-size') == '14px', msg.value_of_css_property('font-size')
    # This color is not represented in the style guide
    assert msg.value_of_css_property('color') == APERTA_FLASH_INFO, msg.value_of_css_property('color')
    # This color is not represented in the style guide
    assert msg.value_of_css_property('background-color') == APERTA_FLASH_INFO_BKGRND, \
        msg.value_of_css_property('background-color')
    assert msg.value_of_css_property('line-height') == '20px', msg.value_of_css_property('line-height')
    assert msg.value_of_css_property('text-align') == 'center', msg.value_of_css_property('text-align')
    assert msg.value_of_css_property('position') == 'relative', msg.value_of_css_property('position')
    assert msg.value_of_css_property('display') == 'inline-block', msg.value_of_css_property('display')

  @staticmethod
  def validate_error_field_style(field):
    """
    Ensure consistency in rendering warning alerts across the application
    :field: field to validate
    """
    assert field.value_of_css_property('border-top-color') == 'rgba(206, 11, 37, 1)', \
        field.value_of_css_property('border-top-color')
    assert field.value_of_css_property('border-left-color') == 'rgba(206, 11, 37, 1)', \
        field.value_of_css_property('border-left-color')
    assert field.value_of_css_property('border-right-color') == 'rgba(206, 11, 37, 1)', \
        field.value_of_css_property('border-right-color')
    assert field.value_of_css_property('border-bottom-color') == 'rgba(206, 11, 37, 1)', \
        field.value_of_css_property('border-bottom-color')
    assert field.value_of_css_property('border-style') == 'solid', \
        field.value_of_css_property('border-style')
    assert field.value_of_css_property('border-radius') == '3px', \
        field.value_of_css_property('border-radius')

  @staticmethod
  def validate_error_msg_field_style(field):
    """
    Ensure consistency in rendering warning alerts across the application
    :field: field to validate
    """
    assert field.value_of_css_property('color')  == 'rgba(208, 2, 27, 1)', \
        field.value_of_css_property('color')
    assert field.value_of_css_property('font-size') == '14px', \
        field.value_of_css_property('font-size')
    assert field.value_of_css_property('line-height') == '20px', \
        field.value_of_css_property('line-height')

  def validate_rescind_decision_success_style(msg):
    """
    Ensure consistency in rendering success alerts for rescind decision elements
    :param msg: alert message to validate
    """
    assert APPLICATION_TYPEFACE in msg.value_of_css_property('font-family'), \
        msg.value_of_css_property('font-family')
    assert msg.value_of_css_property('font-size') == '14px', msg.value_of_css_property('font-size')
    # This color is not represented in the tahi palette
    assert msg.value_of_css_property('color') == APERTA_BLACK, \
        msg.value_of_css_property('color')
    assert msg.value_of_css_property('line-height') == '20px', \
        msg.value_of_css_property('line-height')


  def validate_rescind_decision_info_style(msg):
    """
    Ensure consistency in rendering informational alerts for rescind decision elements
    :param msg: alert message to validate
    """
    assert APPLICATION_TYPEFACE in msg.value_of_css_property('font-family'), \
        msg.value_of_css_property('font-family')
    assert msg.value_of_css_property('font-size') == '18px', msg.value_of_css_property('font-size')
    # This color is not represented in the tahi palette
    assert msg.value_of_css_property('color') == APERTA_BLACK, \
        msg.value_of_css_property('color')
    assert msg.value_of_css_property('background-color') == APERTA_GREY_XLIGHT, \
        msg.value_of_css_property('background-color')
    assert msg.value_of_css_property('line-height') == '19.8px', \
        msg.value_of_css_property('line-height')

  def validate_rescind_decision_info_revision_style(msg):
    """
    Ensure consistency in rendering revision information in informational alerts for rescind
      decision elements
    :param msg: alert message to validate
    """
    assert APPLICATION_TYPEFACE in msg.value_of_css_property('font-family'), \
        msg.value_of_css_property('font-family')
    assert msg.value_of_css_property('font-size') == '18px', msg.value_of_css_property('font-size')
    assert msg.value_of_css_property('color') == APERTA_BLACK, \
        msg.value_of_css_property('color')
    assert msg.value_of_css_property('line-height') == '19.8px', \
        msg.value_of_css_property('line-height')
    assert msg.value_of_css_property('font-weight') == 700, msg.value_of_css_property('font-weight')

  def validate_rescind_decision_info_rescinded_flag(msg):
    """
    Ensure consistency in rendering rescinded information in informational alerts for rescind
      decision elements
    :param msg: alert message to validate
    """
    assert APPLICATION_TYPEFACE in msg.value_of_css_property('font-family'), \
      msg.value_of_css_property('font-family')
    assert msg.value_of_css_property('font-size') == '14px', msg.value_of_css_property('font-size')
    # This color is not represented in the tahi palette
    assert msg.value_of_css_property('color') == APERTA_BLACK, \
        msg.value_of_css_property('color')
    assert msg.value_of_css_property('background-color') == 'rgba(108, 108, 108, 1)', \
      msg.value_of_css_property('background-color')
    assert msg.value_of_css_property('line-height') == '19.8px', \
        msg.value_of_css_property('line-height')
    assert msg.value_of_css_property('font-weight') == 700, msg.value_of_css_property('font-weight')

  @staticmethod
  def validate_warning_message_style(warning, message):
    """
    Ensure consistency in rendering warning across confirmation
    :param warning: Warning element
    """
    assert warning.text == message, '{0} not {1}'.format(warning.text, message)
    assert APPLICATION_TYPEFACE in warning.value_of_css_property('font-family'), \
        warning.value_of_css_property('font-family')
    assert warning.value_of_css_property('font-size') == '18px', \
        warning.value_of_css_property('font-size')
    assert warning.value_of_css_property('font-weight') == '500', \
        warning.value_of_css_property('font-weight')
    assert warning.value_of_css_property('line-height') == '19.8px', \
        warning.value_of_css_property('line-height')
    assert warning.value_of_css_property('color') == WHITE, \
        warning.value_of_css_property('color')
    assert warning.value_of_css_property('text-align') == 'center', \
        warning.value_of_css_property('text-align')
    assert warning.value_of_css_property('vertical-align') == 'baseline', \
        warning.value_of_css_property('vertical-align')

  # Avatar Styles =============================
  @staticmethod
  def validate_large_avatar_style(avatar):
    """
    Ensure consistency in rendering large avatars across the application
    :param avatar: avatar to validate
    """
    assert APPLICATION_TYPEFACE in avatar.value_of_css_property('font-family'), \
        avatar.value_of_css_property('font-family')
    assert avatar.value_of_css_property('font-size') == '14px', avatar.value_of_css_property('font-size')
    # These colors are not represented in the style guide
    assert avatar.value_of_css_property('color') == APERTA_BLACK, avatar.value_of_css_property('color')
    assert avatar.value_of_css_property('line-height') == '20px', avatar.value_of_css_property('line-height')
    assert avatar.value_of_css_property('vertical-align') == 'middle', avatar.value_of_css_property('vertical-align')
    assert avatar.value_of_css_property('width') == '160px', avatar.value_of_css_property('width')
    assert avatar.value_of_css_property('height') == '160px', avatar.value_of_css_property('height')

  @staticmethod
  def validate_large_avatar_hover_style(avatar):
    """
    Ensure consistency in rendering large avatar hover states across the application
    :param avatar: avatar to validate
    """
    assert APPLICATION_TYPEFACE in avatar.value_of_css_property('font-family'), \
        avatar.value_of_css_property('font-family')
    assert avatar.value_of_css_property('font-size') == '14px', avatar.value_of_css_property('font-size')
    # This color is not represented in the style guide
    assert avatar.value_of_css_property('color') == APERTA_GREEN_DARK, avatar.value_of_css_property('color')
    assert avatar.value_of_css_property('background-color') == APERTA_GREEN_LIGHT, \
        avatar.value_of_css_property('background-color')
    assert avatar.value_of_css_property('line-height') == '20px', avatar.value_of_css_property('line-height')
    assert avatar.value_of_css_property('vertical-align') == 'middle', avatar.value_of_css_property('vertical-align')

  @staticmethod
  def validate_thumbnail_avatar_style(avatar):
    """
    Ensure consistency in rendering thumbnail avatars across the application
    :param avatar: avatar to validate
    """
    assert APPLICATION_TYPEFACE in avatar.value_of_css_property('font-family'), \
        avatar.value_of_css_property('font-family')
    assert avatar.value_of_css_property('font-size') == '14px', avatar.value_of_css_property('font-size')
    # These colors are not represented in the style guide
    assert avatar.value_of_css_property('color') == APERTA_BLACK, avatar.value_of_css_property('color')
    assert avatar.value_of_css_property('line-height') == '20px', avatar.value_of_css_property('line-height')
    assert avatar.value_of_css_property('vertical-align') == 'middle', avatar.value_of_css_property('vertical-align')
    assert avatar.value_of_css_property('width') == '32px', avatar.value_of_css_property('width')
    assert avatar.value_of_css_property('height') == '32px', avatar.value_of_css_property('height')

  @staticmethod
  def validate_small_thumbnail_avatar_style(avatar):
    """
    Ensure consistency in rendering thumbnail avatars across the application
    :param avatar: avatar to validate
    """
    assert APPLICATION_TYPEFACE in avatar.value_of_css_property('font-family'), \
        avatar.value_of_css_property('font-family')
    assert avatar.value_of_css_property('font-size') == '14px', avatar.value_of_css_property('font-size')
    # These colors are not represented in the style guide
    assert avatar.value_of_css_property('color') == APERTA_BLACK, avatar.value_of_css_property('color')
    assert avatar.value_of_css_property('line-height') == '20px', avatar.value_of_css_property('line-height')
    assert avatar.value_of_css_property('vertical-align') == 'middle', avatar.value_of_css_property('vertical-align')
    assert avatar.value_of_css_property('width') == '25px', avatar.value_of_css_property('width')
    assert avatar.value_of_css_property('height') == '25px', avatar.value_of_css_property('height')

  # Activity Overlay Styles ==================
  # Why does this one overlay get it's own styles?
  @staticmethod
  def validate_activity_message_style(msg):
    """
    Ensure consistency in rendering activity list messages
    :param msg: activity message to validate
    """
    assert APPLICATION_TYPEFACE in msg.value_of_css_property('font-size'), msg.value_of_css_property('font-size')
    assert msg.value_of_css_property('font-size') == '17px', msg.value_of_css_property('font-size')
    # This color is not represented in the style guide
    assert msg.value_of_css_property('line-height') == APERTA_BLACK, msg.value_of_css_property('line-height')
    assert msg.value_of_css_property('line-height') == '24.2833px', msg.value_of_css_property('line-height')
    assert msg.value_of_css_property('padding-top') == '0px', msg.value_of_css_property('padding-top')
    assert msg.value_of_css_property('padding-right') == '15px', msg.value_of_css_property('padding-right')
    assert msg.value_of_css_property('padding-bottom') == '25px', msg.value_of_css_property('padding-bottom')
    assert msg.value_of_css_property('padding-left') == '0px', msg.value_of_css_property('padding-left')

  @staticmethod
  def validate_activity_timestamp_style(timestamp):
    """
    Ensure consistency in rendering activity list timestamps
    :param timestamp: timestamp to validate
    """
    assert APPLICATION_TYPEFACE in timestamp.value_of_css_property('font-size'), \
        timestamp.value_of_css_property('font-size')
    assert timestamp.value_of_css_property('font-size') == '14px', timestamp.value_of_css_property('font-size')
    # This color is not represented in the style guide
    assert timestamp.value_of_css_property('line-height') == APERTA_BLACK, \
        timestamp.value_of_css_property('line-height')
    assert timestamp.value_of_css_property('line-height') == '20px', timestamp.value_of_css_property('line-height')
    assert timestamp.value_of_css_property('padding-top') == '0px', timestamp.value_of_css_property('padding-top')
    assert timestamp.value_of_css_property('padding-right') == '15px', timestamp.value_of_css_property('padding-right')
    assert timestamp.value_of_css_property('padding-bottom') == '25px', \
        timestamp.value_of_css_property('padding-bottom')
    assert timestamp.value_of_css_property('padding-left') == '0px', timestamp.value_of_css_property('padding-left')

  # Progress Styles ==========================
  @staticmethod
  def validate_progress_spinner_style(spinner):
    """
    Ensure consistency in rendering progress spinners across the application
    :param spinner: spinner to validate
    """
    assert APPLICATION_TYPEFACE in spinner.value_of_css_property('font-family'), \
        spinner.value_of_css_property('font-family')
    assert spinner.value_of_css_property('font-size') == '14px', spinner.value_of_css_property('font-size')
    # These colors are not represented in the style guide
    assert spinner.value_of_css_property('color') == APERTA_BLACK, spinner.value_of_css_property('color')
    assert spinner.value_of_css_property('line-height') == '20px', spinner.value_of_css_property('line-height')
    assert spinner.value_of_css_property('width') == '50px', spinner.value_of_css_property('width')
    assert spinner.value_of_css_property('height') == '50px', spinner.value_of_css_property('height')

  # Table Styles =============================
  # None of these are currently represented in the style guide and there is a lot of variance in the app
  @staticmethod
  def validate_table_heading_style(th):
    """
    Ensure consistency in rendering table headings across the application
    :param th: table heading to validate
    """
    assert APPLICATION_TYPEFACE in th.value_of_css_property('font-family'), th.value_of_css_property('font-family')
    assert th.value_of_css_property('font-size') == '14px', th.value_of_css_property('font-size')
    assert th.value_of_css_property('font-weight') == '700', th.value_of_css_property('font-weight')
    assert th.value_of_css_property('line-height') == '20px', th.value_of_css_property('line-height')
    # This color is not represented in the tahi palette
    assert th.value_of_css_property('color') == APERTA_BLACK, th.value_of_css_property('color')
    assert th.value_of_css_property('text-align') == 'left', th.value_of_css_property('text-align')
    assert th.value_of_css_property('vertical-align') == 'top', th.value_of_css_property('vertical-align')

  @staticmethod
  def validate_file_title_style(ft):
    """
    Ensure consistency in rendering the file title in SI Card
    :param ft: File title to validate
    """
    assert APPLICATION_TYPEFACE in ft.value_of_css_property('font-family'), \
        ft.value_of_css_property('font-family')
    assert ft.value_of_css_property('font-size') == '14px', ft.value_of_css_property('font-size')
    assert ft.value_of_css_property('font-weight') == '700', \
        ft.value_of_css_property('font-weight')
    assert ft.value_of_css_property('line-height') == '20px', \
        ft.value_of_css_property('line-height')
    # This color is not represented in the tahi palette
    assert ft.value_of_css_property('color') == APERTA_BLACK, ft.value_of_css_property('color')
