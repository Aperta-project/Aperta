#!/usr/bin/env python3
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

import logging

from Base.PlosPage import PlosPage

__author__ = 'jgray@plos.org'
# Variable definitions

# typefaces
APPLICATION_TYPEFACE = 'source-sans-pro'
APPLICATION_TYPEFACE_ITALIC = 'source-sans-pro-it'
MANUSCRIPT_TYPEFACE = 'lora'

# Attention, only colors defined in the Color palette section of the style guide should be
#   represented here. Anything not defined in the color palette should be pushed into the specific
#   validation method.
# colors
APERTA_GREEN = 'rgb(57, 163, 41)'
APERTA_GREEN_LIGHT = 'rgb(142, 203, 135)'
APERTA_GREEN_DARK = 'rgb(15, 116, 0)'
APERTA_RED = 'rgb(206, 11, 36)'
APERTA_BLUE = 'rgb(45, 133, 222)'
APERTA_BUTTON_BLUE = 'rgb(231, 243, 254)'
APERTA_BLUE_LIGHT = 'rgb(215, 235, 254)'
APERTA_BLUE_DARK = 'rgb(32, 94, 156)'
APERTA_GREY_XLIGHT = 'rgb(245, 245, 245)'
APERTA_GREY_LIGHT = 'rgb(213, 213, 213)'
APERTA_GREY_DARK = 'rgb(135, 135, 135)'
APERTA_BLACK = 'rgb(51, 51, 51)'
APERTA_ERROR = 'rgb(206, 11, 36)'
WHITE = 'rgb(255, 255, 255)'
BLACK = 'rgb(0, 0, 0)'
TRANSPARENT = 'rgba(0, 0, 0, 0)'


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
        Examples where used: Page Title
        :param title: title to validate
        Updated for new style guide: https://app.zeplin.io/project.html
        """
        assert APPLICATION_TYPEFACE in title.value_of_css_property('font-family'), \
            title.value_of_css_property('font-family')
        assert title.value_of_css_property('font-size') == '48px', \
            title.value_of_css_property('font-size')
        # assert title.value_of_css_property('line-height') == '52px', \
        #     title.value_of_css_property('line-height')
        # font-weight is canonically specified as 'normal' whatever that means.
        assert title.value_of_css_property('font-weight') == '500', \
            title.value_of_css_property('font-weight')
        assert title.value_of_css_property('color') == APERTA_BLACK, \
            title.value_of_css_property('color')

    @staticmethod
    def validate_application_section_heading_style(title, admin=False):
        """
        Ensure consistency in rendering section headings across the application
        Examples where used: Card section name
        :param title: title to validate
        :param admin: a boolean indicating whether the title appears in the admin section and is
          thus blue
        """
        assert APPLICATION_TYPEFACE in title.value_of_css_property('font-family'), \
            title.value_of_css_property('font-family')
        assert title.value_of_css_property('font-size') == '30px', \
            title.value_of_css_property('font-size')
        assert title.value_of_css_property('line-height') == '33px', \
            title.value_of_css_property('line-height')
        # font-weight is canonically specified as 'normal' whatever that means.
        assert title.value_of_css_property('font-weight') == '500', \
            title.value_of_css_property('font-weight')
        if admin:
            assert title.value_of_css_property('color') == APERTA_BLUE, \
                title.value_of_css_property('color')
        else:
            assert title.value_of_css_property('color') == APERTA_BLACK, \
                title.value_of_css_property('color')

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
        assert title.value_of_css_property('font-size') == '20px', \
            title.value_of_css_property('font-size')
        # APERTA-9305
        # assert title.value_of_css_property('line-height') == '22px',
        #   title.value_of_css_property('line-height')
        assert title.value_of_css_property('font-weight') == '400', \
            title.value_of_css_property('font-weight')
        assert title.value_of_css_property('color') == APERTA_BLACK, \
            title.value_of_css_property('color')

    @staticmethod
    def validate_application_accordion_card_title_style(title):
        """
        Ensure consistency in rendering accordion card titles and headings across the application
        Not used for the Manuscript Title!
        :param title: title to validate
        Updated for new style guide: https://app.zeplin.io/project.html
        """
        assert APPLICATION_TYPEFACE in title.value_of_css_property('font-family'), \
            title.value_of_css_property('font-family')
        assert title.value_of_css_property('font-size') == '18px', \
            title.value_of_css_property('font-size')
        assert title.value_of_css_property('line-height') == '23px', \
            title.value_of_css_property('line-height')
        assert title.value_of_css_property('font-weight') == '400', \
            title.value_of_css_property('font-weight')
        assert title.value_of_css_property('color') == APERTA_BLACK, \
            title.value_of_css_property('color')

    @staticmethod
    def validate_card_question_text(question):
        """
        Ensure consistency in rendering application question text in cards
        :param question: question to validate
        :return: Void Function
        """
        assert APPLICATION_TYPEFACE in question.value_of_css_property('font-family').lower(), \
            question.value_of_css_property('font-family')
        assert question.value_of_css_property('font-size') == '16px', \
            question.value_of_css_property('font-size')
        assert question.value_of_css_property('font-weight') == '400', \
            question.value_of_css_property('font-weight')
        assert question.value_of_css_property('color') == APERTA_BLACK, \
            question.value_of_css_property('color')

    @staticmethod
    def validate_application_body_text(paragraph):
        """
        Ensure consistency in rendering application ordinary text and paragraph text across
          the application
        :param paragraph: paragraph to validate
        :return: Void Function
        """
        assert APPLICATION_TYPEFACE in paragraph.value_of_css_property('font-family'), \
            paragraph.value_of_css_property('font-family')
        assert paragraph.value_of_css_property('font-size') == '14px', \
            paragraph.value_of_css_property('font-size')
        assert paragraph.value_of_css_property('color') == APERTA_BLACK, \
            paragraph.value_of_css_property('color')

    # TODO: Define label style

    # NOTA BENE: This is incorrect per the v.1.1 style guide but correct per usage - the style guide
    #   definition seems bunk - need to check in with Sebastian Toomey
    @staticmethod
    def validate_input_field_placeholder_style(placeholder):
        """
        Ensure consistency in rendering page, card and overlay internal input field placeholders
          across the application
        :param placeholder: text to validate
        """
        assert APPLICATION_TYPEFACE in placeholder.value_of_css_property('font-family')
        assert placeholder.value_of_css_property('font-size') == '14px', \
            placeholder.value_of_css_property('font-size')
        assert placeholder.value_of_css_property('line-height') == '20px', \
            placeholder.value_of_css_property('line-height')
        assert placeholder.value_of_css_property('font-weight') == '400', \
            placeholder.value_of_css_property('font-weight')
        assert placeholder.value_of_css_property('color') == APERTA_GREY_DARK, \
            placeholder.value_of_css_property('color')

    @staticmethod
    def validate_manuscript_title_style(title):
        """
        Ensure consistency in rendering page and overlay main headings within the manuscript
        :param title: title to validate
        """
        assert MANUSCRIPT_TYPEFACE in title.value_of_css_property('font-family'), \
            title.value_of_css_property('font-family')
        assert title.value_of_css_property('font-size') == '36px', \
            title.value_of_css_property('font-size')
        assert title.value_of_css_property('font-weight') == '500', \
            title.value_of_css_property('font-weight')
        assert title.value_of_css_property('line-height') == '39.6px', \
            title.value_of_css_property('line-height')
        assert title.value_of_css_property('color') == APERTA_BLACK, \
            title.value_of_css_property('color')

    @staticmethod
    def validate_manuscript_h2_style(title):
        """
        Ensure consistency in rendering page and overlay h2 section headings within the manuscript
        :param title: Title to validate
        """
        assert MANUSCRIPT_TYPEFACE in title.value_of_css_property('font-family'), \
            title.value_of_css_property('font-family')
        assert title.value_of_css_property('font-size') == '30px', \
            title.value_of_css_property('font-size')
        assert title.value_of_css_property('font-weight') == '500', \
            title.value_of_css_property('font-weight')
        assert title.value_of_css_property('line-height') == '33px', \
            title.value_of_css_property('line-height')
        assert title.value_of_css_property('color') == APERTA_BLACK, \
            title.value_of_css_property('color')

    @staticmethod
    def validate_manuscript_h3_style(title):
        """
        Ensure consistency in rendering page and overlay h3 section headings within the manuscript
        :param title: title to validate
        """
        assert MANUSCRIPT_TYPEFACE in title.value_of_css_property('font-family'), \
            title.value_of_css_property('font-family')
        assert title.value_of_css_property('font-size') == '24px', \
            title.value_of_css_property('font-size')
        assert title.value_of_css_property('font-weight') == '500', \
            title.value_of_css_property('font-weight')
        assert title.value_of_css_property('line-height') == '26.4px', \
            title.value_of_css_property('line-height')
        assert title.value_of_css_property('color') == APERTA_BLACK, \
            title.value_of_css_property('color')

    @staticmethod
    def validate_manuscript_h4_style(title):
        """
        Ensure consistency in rendering page and overlay h4 section headings within the manuscript
        :param title: title to validate
        """
        assert MANUSCRIPT_TYPEFACE in title.value_of_css_property('font-family'), \
            title.value_of_css_property('font-family')
        assert title.value_of_css_property('font-size') == '18px', \
            title.value_of_css_property('font-size')
        assert title.value_of_css_property('font-weight') == '500', \
            title.value_of_css_property('font-weight')
        assert title.value_of_css_property('line-height') == '19.8px', \
            title.value_of_css_property('line-height')
        assert title.value_of_css_property('color') == APERTA_BLACK, \
            title.value_of_css_property('color')

    @staticmethod
    def validate_manuscript_body_text(paragraph):
        """
        Ensure consistency in rendering manuscript ordinary text and paragraph text across
          the application
        :param paragraph: paragraph to validate
        :return: Void Function
        """
        assert MANUSCRIPT_TYPEFACE in paragraph.value_of_css_property('font-family'), \
            paragraph.value_of_css_property('font-family')
        assert paragraph.value_of_css_property('font-size') == '14px', \
            paragraph.value_of_css_property('font-size')
        assert paragraph.value_of_css_property('font-weight') == '400', \
            paragraph.value_of_css_property('font-weight')
        assert paragraph.value_of_css_property('line-height') == '20px', \
            paragraph.value_of_css_property('line-height')
        # This color is not represented in the tahi palette
        assert paragraph.value_of_css_property('color') == APERTA_BLACK, \
            paragraph.value_of_css_property('color')

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
    @staticmethod
    def validate_overlay_card_title_style(title):
        """
        Ensure consistency in rendering Card Titles across the application
        Examples where used: Card title
        :param title: title to validate
        Updated for new style guide: https://app.zeplin.io/project.html
        """
        assert APPLICATION_TYPEFACE in title.value_of_css_property('font-family'), \
            title.value_of_css_property('font-family')
        assert title.value_of_css_property('font-size') == '48px', \
            title.value_of_css_property('font-size')
        # APERTA-9552
        # assert title.value_of_css_property('line-height') == '60px',
        #   title.value_of_css_property('line-height')
        # font-weight is canonically specified as 'normal' whatever that means.
        assert title.value_of_css_property('color') == APERTA_BLACK, \
            title.value_of_css_property('color')

    # ===================================================
    # Tables ============================================
    @staticmethod
    def validate_table_heading_style(th, selected=False):
        """
        Validate a basic column header (th)
        :param th: the column header to validate
        :param selected: whether the column is selected as in a sort, default value=False
        :return: void function
        """
        assert APPLICATION_TYPEFACE in th.value_of_css_property('font-family'), \
            th.value_of_css_property('font-family')
        assert th.value_of_css_property('font-size') == '14px', th.value_of_css_property(
            'font-size')
        assert th.value_of_css_property('line-height') == '20px', \
            th.value_of_css_property('line-height')
        assert th.value_of_css_property('color') == APERTA_BLACK, th.value_of_css_property('color')
        if selected:
            assert th.value_of_css_property('font-weight') == '700', \
                th.value_of_css_property('font-weight')
        else:
            # font-weight is canonically specified as 'normal' whatever that means.
            assert th.value_of_css_property('font-weight') == '500', \
                th.value_of_css_property('font-weight')

    @staticmethod
    def validate_table_data_item(td, highlighted=False):
        """
        Validate a basic column/row item (td)
        :param td: the td element to validate
        :param highlighted: whether the column is selected or otherwise highlighted,
          default value=False
        :return: void function
        """
        assert APPLICATION_TYPEFACE in td.value_of_css_property('font-family'), \
            td.value_of_css_property('font-family')
        assert td.value_of_css_property('font-size') == '14px', td.value_of_css_property(
            'font-size')
        assert td.value_of_css_property('line-height') == '20px', \
            td.value_of_css_property('line-height')
        assert td.value_of_css_property('color') == APERTA_BLACK, td.value_of_css_property('color')
        if highlighted:
            assert td.value_of_css_property('background-color') == APERTA_GREY_LIGHT, \
                td.value_of_css_property('background-color')
        else:
            assert td.value_of_css_property('background-color') == WHITE, \
                td.value_of_css_property('background-color')

    # ===================================================
    # Components ========================================
    @staticmethod
    def validate_flash_error_style(msg):
        """
        Ensure consistency in rendering error alerts across the application
        :param msg: alert message to validate
        """
        assert APPLICATION_TYPEFACE in msg.value_of_css_property('font-family'), \
            msg.value_of_css_property('font-family')
        assert msg.value_of_css_property('font-size') == '14px', msg.value_of_css_property(
            'font-size')
        assert msg.value_of_css_property('line-height') == '22px', \
            msg.value_of_css_property('line-height')
        assert msg.value_of_css_property('text-align') == 'center', \
            msg.value_of_css_property('text-align')
        # This color is not represented in the style guide in our palette
        assert msg.value_of_css_property('color') == 'rgba(122, 51, 78, 1)', \
            msg.value_of_css_property('color')
        # This color is not represented in the style guide in our palette
        assert msg.value_of_css_property('background-color') == 'rgba(247, 239, 233, 1)', \
            msg.value_of_css_property('background-color')

    @staticmethod
    def validate_flash_success_style(msg):
        """
        Ensure consistency in rendering success alerts across the application
        :param msg: alert message to validate
        """
        assert APPLICATION_TYPEFACE in msg.value_of_css_property('font-family'), \
            msg.value_of_css_property('font-family')
        assert msg.value_of_css_property('font-size') == '14px', msg.value_of_css_property(
            'font-size')
        assert msg.value_of_css_property('line-height') == '18px', \
            msg.value_of_css_property('line-height')
        assert msg.value_of_css_property('text-align') == 'center', \
            msg.value_of_css_property('text-align')
        assert msg.value_of_css_property('color') == APERTA_GREEN, msg.value_of_css_property(
            'color')
        # This color is not represented in the style guide in our palette
        assert msg.value_of_css_property('background-color') == 'rgba(234, 253, 231, 1)', \
            msg.value_of_css_property('background-color')

    @staticmethod
    def validate_flash_warn_style(msg):
        """
        Ensure consistency in rendering warning alerts across the application
        :param msg: alert message to validate
        """
        assert APPLICATION_TYPEFACE in msg.value_of_css_property(
                'font-family'), msg.value_of_css_property('font-family')
        assert msg.value_of_css_property('font-size') == '14px', msg.value_of_css_property(
            'font-size')
        assert msg.value_of_css_property('line-height') == '18px', \
            msg.value_of_css_property('line-height')
        assert msg.value_of_css_property('text-align') == 'center', \
            msg.value_of_css_property('text-align')
        # This color is not represented in the style guide in our palette
        assert msg.value_of_css_property('color') == 'rgba(146, 139, 112, 1)', \
            msg.value_of_css_property('color')
        # This color is not represented in the style guide in our palette
        assert msg.value_of_css_property('background-color') == 'rgba(242, 242, 214, 1)', \
            msg.value_of_css_property('background-color')

    @staticmethod
    def validate_flash_fatal_error_title_style(msg):
        """
        Ensure consistency in rendering informational alerts across the application
        :param msg: alert message to validate
        """
        assert APPLICATION_TYPEFACE in msg.value_of_css_property('font-family'), \
            msg.value_of_css_property('font-family')
        assert msg.value_of_css_property('font-size') == '18px', msg.value_of_css_property(
            'font-size')
        assert msg.value_of_css_property('line-height') == '20px', \
            msg.value_of_css_property('line-height')
        assert msg.value_of_css_property('text-align') == 'center', \
            msg.value_of_css_property('text-align')
        # This color is not represented in the style guide in our palette
        assert msg.value_of_css_property('color') == 'rgba(245, 245, 245, 1)', \
            msg.value_of_css_property('color')

    @staticmethod
    def validate_flash_fatal_error_body_style(msg):
        """
        Ensure consistency in rendering informational alerts across the application
        :param msg: alert message to validate
        """
        assert APPLICATION_TYPEFACE in msg.value_of_css_property('font-family'), \
            msg.value_of_css_property('font-family')
        assert msg.value_of_css_property('font-size') == '14px', msg.value_of_css_property(
            'font-size')
        assert msg.value_of_css_property('line-height') == '20px', \
            msg.value_of_css_property('line-height')
        assert msg.value_of_css_property('text-align') == 'center', \
            msg.value_of_css_property('text-align')
        # This color is not represented in the style guide in our palette
        assert msg.value_of_css_property('color') == 'rgba(245, 245, 245, 1)', \
            msg.value_of_css_property('color')

    @staticmethod
    def validate_static_notification_style(msg):
        """
        Ensure consistency in static notifications across the application
        :param msg: notification message to validate
        """
        assert APPLICATION_TYPEFACE in msg.value_of_css_property('font-family'), \
            msg.value_of_css_property('font-family')
        assert msg.value_of_css_property('font-size') == '14px', msg.value_of_css_property(
            'font-size')
        # APERTA-9649
        # assert msg.value_of_css_property('line-height') == '18px', \
        #     msg.value_of_css_property('line-height')
        assert msg.value_of_css_property('color') == APERTA_BLACK, \
            '{0} not equal to {1}'.format(APERTA_BLACK, msg.value_of_css_property('color'))
        # This color is not represented in the tahi palette
        # Also allow for this being implemented on the correct color background directly or as a
        #   transparency atop a box of correct color
        assert msg.value_of_css_property('background-color') in ('rgb(234, 253, 231)',
                                                                 TRANSPARENT), \
            msg.value_of_css_property('background-color')

    # OLD Non-clean, pre v.1. style guide definitions are all below here ##########################
    # Divider and Border Styles ===========================

    @staticmethod
    def validate_light_background_border(border):
        """
        This border style is used against the $color-light variants only
        :param border: border
        :return: Void function
        """
        # This color is not represented in the tahi palette
        assert border.value_of_css_property('color') == 'rgba(128, 128, 128, 1)', \
            border.value_of_css_property('color')
        assert border.value_of_css_property('background-color') in (APERTA_GREEN_LIGHT,
                                                                    APERTA_BLUE_LIGHT,
                                                                    APERTA_GREY_LIGHT), \
            border.value_of_css_property('background-color')

    @staticmethod
    def validate_standard_border(border):
        """
        This border style is used against all but the light color variants.
        :param border: border
        :return: Void function
        """
        # This color is not represented in the tahi palette
        assert border.value_of_css_property('color') == APERTA_BLACK, \
            border.value_of_css_property('color')

    # Heading Styles ===========================
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
        assert title.value_of_css_property('font-size') == '14px', \
            title.value_of_css_property('font-size')
        assert title.value_of_css_property('font-weight') == '500', \
            title.value_of_css_property('font-weight')
        assert title.value_of_css_property('line-height') == '15.4px', \
            title.value_of_css_property('line-height')
        # This color is not represented in the tahi palette
        assert title.value_of_css_property('color') == 'rgba(153, 153, 153, 1)', \
            title.value_of_css_property('color')

    @staticmethod
    def validate_application_h2_style(title):
        """
        Ensure consistency in rendering page and overlay h2 section headings across the application
        :param title: title to validate
        """
        assert APPLICATION_TYPEFACE in title.value_of_css_property('font-family'), \
            title.value_of_css_property('font-family')
        assert title.value_of_css_property('font-size') == '30px', \
            title.value_of_css_property('font-size')
        assert title.value_of_css_property('line-height') == '33px', \
            title.value_of_css_property('line-height')
        assert title.value_of_css_property('font-weight') == '500', \
            title.value_of_css_property('font-weight')
        assert title.value_of_css_property('color') == APERTA_BLACK, \
            title.value_of_css_property('color')

    @staticmethod
    def validate_application_h3_style(title):
        """
        Ensure consistency in rendering page and overlay h3 section headings across the application
        :param title: title to validate
        """
        assert APPLICATION_TYPEFACE in title.value_of_css_property('font-family'), \
            title.value_of_css_property('font-family')
        assert title.value_of_css_property('font-size') == '24px', \
            title.value_of_css_property('font-size')
        assert title.value_of_css_property('font-weight') == '500', \
            title.value_of_css_property('font-weight')
        assert title.value_of_css_property('line-height') == '26.4px', \
            title.value_of_css_property('line-height')
        assert title.value_of_css_property('color') == APERTA_BLACK, \
            title.value_of_css_property('color')

    @staticmethod
    def validate_application_h4_style(title):
        """
        Ensure consistency in rendering page and overlay h4 section headings across the application
        :param title: title to validate
        """
        assert APPLICATION_TYPEFACE in title.value_of_css_property('font-family'), \
            title.value_of_css_property('font-family')
        assert title.value_of_css_property('font-size') == '18px', \
            title.value_of_css_property('font-size')
        assert title.value_of_css_property('font-weight') == '500', \
            title.value_of_css_property('font-weight')
        assert title.value_of_css_property('color') == APERTA_BLACK, \
            title.value_of_css_property('color')

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
            '{0) is not equal to {1}'.format(title.value_of_css_property('font-weight'),
                                             font_weight)
        assert title.value_of_css_property('line-height') == line_height, \
            '{0) is not equal to {1}'.format(title.value_of_css_property('line-height'),
                                             line_height)
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
    def validate_action_status_text(message):
        """In some places in the app, we give a status message in a large green font"""
        assert APPLICATION_TYPEFACE in message.value_of_css_property('font-family'), \
            message.value_of_css_property('font-family')
        assert message.value_of_css_property('font-size') == '16px', \
            message.value_of_css_property('font-size')
        assert message.value_of_css_property('line-height') == '22.85px', \
            message.value_of_css_property('line-height')
        assert message.value_of_css_property('color') == APERTA_GREEN, \
            message.value_of_css_property('color')

    # Link Styles ==============================
    @staticmethod
    def validate_default_link_style(link):
        """
        Ensure consistency in rendering links across the application
        :param link: link to validate
        """
        assert APPLICATION_TYPEFACE in link.value_of_css_property('font-family'), \
            link.value_of_css_property('font-family')
        assert link.value_of_css_property('font-size') == '14px', \
            link.value_of_css_property('font-size')
        assert link.value_of_css_property('line-height') == '20px', \
            link.value_of_css_property('line-height')
        assert link.value_of_css_property('background-color') == TRANSPARENT, \
            link.value_of_css_property('background-color')
        assert link.value_of_css_property('color') == APERTA_GREEN, \
            link.value_of_css_property('color')
        assert link.value_of_css_property('font-weight') == '400', \
            link.value_of_css_property('font-weight')

    @staticmethod
    def validate_filename_link_style(link):
        """
        Ensure consistency in rendering special file links across the application
        This style is listed as a block style in the style guide.
        :param link: link to validate
        """
        assert APPLICATION_TYPEFACE in link.value_of_css_property('font-family'), \
            link.value_of_css_property('font-family')
        assert link.value_of_css_property('font-size') == '18px', \
            link.value_of_css_property('font-size')
        assert link.value_of_css_property('background-color') == TRANSPARENT, \
            link.value_of_css_property('background-color')
        assert link.value_of_css_property('color') == APERTA_GREEN, \
            link.value_of_css_property('color')
        assert link.value_of_css_property('font-weight') == '400', \
            link.value_of_css_property('font-weight')

    @staticmethod
    def validate_mention_style(element):
        """
        Validate style of the mention
        """
        assert APPLICATION_TYPEFACE in element.value_of_css_property('font-family'), \
            element.value_of_css_property('font-family')
        assert element.value_of_css_property('color') == APERTA_GREEN, \
            element.value_of_css_property('color')
        assert element.value_of_css_property('font-size') == '14px', \
            element.value_of_css_property('font-size')
        assert element.value_of_css_property('line-height') == '18.2px', \
            element.value_of_css_property('line-height')
        assert element.value_of_css_property('font-weight') == '400', \
            element.value_of_css_property('font-weight')

    @staticmethod
    def validate_profile_link_style(link):
        """
        Links valid in profile page
        :param link: link to validate
        """
        assert APPLICATION_TYPEFACE in link.value_of_css_property('font-family'), \
            link.value_of_css_property('font-family')
        assert link.value_of_css_property('font-size') == '14px', \
            link.value_of_css_property('font-size')
        assert link.value_of_css_property('line-height') == '20px', \
            link.value_of_css_property('line-height')
        assert link.value_of_css_property('background-color') == 'transparent', \
            link.value_of_css_property('background-color')
        assert link.value_of_css_property('color') == APERTA_GREEN, \
            link.value_of_css_property('color')
        assert link.value_of_css_property('font-weight') == '700', \
            link.value_of_css_property('font-weight')

    @staticmethod
    def validate_default_link_hover_style(link):
        """
        Ensure consistency in rendering link hover across the application
        :param link: link to validate
        """
        assert APPLICATION_TYPEFACE in link.value_of_css_property('font-family'), \
            link.value_of_css_property('font-family')
        assert link.value_of_css_property('font-size') == '14px', \
            link.value_of_css_property('font-size')
        assert link.value_of_css_property('line-height') == '20px', \
            link.value_of_css_property('line-height')
        assert link.value_of_css_property('background-color') == 'transparent', \
            link.value_of_css_property('background-color')
        assert link.value_of_css_property('color') == APERTA_GREEN, link.value_of_css_property(
            'color')
        assert link.value_of_css_property('font-weight') == '400', \
            link.value_of_css_property('font-weight')
        assert link.value_of_css_property('text-decoration') == 'underline', \
            link.value_of_css_property('text-decoration')

    @staticmethod
    def validate_admin_link_style(link):
        """
        Ensure consistency in rendering links across the application
        :param link: link to validate
        """
        assert APPLICATION_TYPEFACE in link.value_of_css_property('font-family'), \
            link.value_of_css_property('font-family')
        assert link.value_of_css_property('font-size') == '14px', \
            link.value_of_css_property('font-size')
        assert link.value_of_css_property('line-height') == '20px', \
            link.value_of_css_property('line-height')
        assert link.value_of_css_property('background-color') == TRANSPARENT, \
            link.value_of_css_property('background-color')
        assert link.value_of_css_property('color') == APERTA_BLUE, link.value_of_css_property(
            'color')
        assert link.value_of_css_property('font-weight') == '400', \
            link.value_of_css_property('font-weight')

    @staticmethod
    def validate_admin_link_hover_style(link):
        """
        Ensure consistency in rendering link hover across the application
        :param link: link to validate
        """
        assert APPLICATION_TYPEFACE in link.value_of_css_property('font-family'), \
            link.value_of_css_property('font-family')
        assert link.value_of_css_property('font-size') == '14px', \
            link.value_of_css_property('font-size')
        assert link.value_of_css_property('line-height') == '20px', \
            link.value_of_css_property('line-height')
        assert link.value_of_css_property('background-color') == 'transparent', \
            link.value_of_css_property('background-color')
        assert link.value_of_css_property('color') == APERTA_BLUE, link.value_of_css_property(
            'color')
        assert link.value_of_css_property('font-weight') == '400', \
            link.value_of_css_property('font-weight')
        assert link.value_of_css_property('text-decoration') == 'underline', \
            link.value_of_css_property('text-decoration')

    @staticmethod
    def validate_disabled_link_style(link):
        """
        Ensure consistency in rendering links across the application
        :param link: link to validate
        """
        assert APPLICATION_TYPEFACE in link.value_of_css_property('font-family'), \
            link.value_of_css_property('font-family')
        assert link.value_of_css_property('font-size') == '14px', \
            link.value_of_css_property('font-size')
        assert link.value_of_css_property('line-height') == '20px', \
            link.value_of_css_property('line-height')
        assert link.value_of_css_property('background-color') == 'transparent', \
            link.value_of_css_property('background-color')
        # This color is not represented in the tahi palette
        assert link.value_of_css_property('color') == APERTA_BLACK, link.value_of_css_property(
            'color')
        assert link.value_of_css_property('font-weight') == '400', \
            link.value_of_css_property('font-weight')

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
        :param delete: delete element
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
            delete.value_of_css_property('background-color')

    @staticmethod
    def validate_container_confirmation_style(confirm_container):
        """
        Validate confirm container style checking CSS properties
        :param confirm_container: Web element to validate
        :return: void function
        """
        assert 'source-sans-pro' in confirm_container.value_of_css_property('font-family'), \
            confirm_container.value_of_css_property('font-family')
        assert confirm_container.value_of_css_property('font-size') == '14px', \
            confirm_container.value_of_css_property('font-size')
        assert confirm_container.value_of_css_property('font-weight') == '400', \
            confirm_container.value_of_css_property('font-weight')
        assert confirm_container.value_of_css_property('line-height') == '20px', \
            confirm_container.value_of_css_property('line-height')
        assert confirm_container.value_of_css_property('color') == WHITE, \
            confirm_container.value_of_css_property('color')
        assert confirm_container.value_of_css_property('text-align') == 'center', \
            confirm_container.value_of_css_property('text-align')
        assert confirm_container.value_of_css_property('background-color') == APERTA_GREEN, \
            confirm_container.value_of_css_property('background-color')

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
        # This color is not represented in the tahi palette
        assert olul.value_of_css_property('color') == APERTA_BLACK, olul.value_of_css_property(
            'color')

    # Button Styles ============================
    @staticmethod
    def validate_primary_big_green_button_style(button):
        """
        Ensure consistency in rendering page and overlay large green-backed, WHITE text buttons
          across the application
        :param button: button to validate
        """
        assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
            button.value_of_css_property('font-family')
        assert button.value_of_css_property('font-size') == '14px', \
            button.value_of_css_property('font-size')
        assert button.value_of_css_property('font-weight') == '400', \
            button.value_of_css_property('font-weight')
        assert button.value_of_css_property('line-height') == '20px', \
            button.value_of_css_property('line-height')
        assert button.value_of_css_property('color') == WHITE, button.value_of_css_property('color')
        assert button.value_of_css_property('background-color') == APERTA_GREEN, \
            button.value_of_css_property('background-color')
        assert button.value_of_css_property('vertical-align') == 'middle', \
            button.value_of_css_property('vertical-align')
        assert button.value_of_css_property('text-transform') == 'uppercase', \
            button.value_of_css_property('text-transform')
        assert button.value_of_css_property('padding-top') == '6px', \
            button.value_of_css_property('padding-top')
        assert button.value_of_css_property('padding-bottom') == '6px', \
            button.value_of_css_property('padding-bottom')
        assert button.value_of_css_property('padding-left') == '12px', \
            button.value_of_css_property('padding-left')
        assert button.value_of_css_property('padding-right') == '12px', \
            button.value_of_css_property('padding-right')

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
        assert button.value_of_css_property('font-size') == '14px', \
            button.value_of_css_property('font-size')
        assert button.value_of_css_property('font-weight') == '400', \
            button.value_of_css_property('font-weight')
        assert button.value_of_css_property('line-height') == '20px', \
            button.value_of_css_property('line-height')
        assert button.value_of_css_property('color') == WHITE, button.value_of_css_property('color')
        # Sometimes selenium locates its virtual cursor in the wrong place and we get a hover
        #   background color instead. In this corner case, don't fail the test, just warn.
        try:
            assert button.value_of_css_property('background-color') == APERTA_GREEN, \
                button.value_of_css_property('background-color')
        except AssertionError:
            logging.warning(
                'Button background color not the expected value {0}'.format(APERTA_GREEN))
        assert button.value_of_css_property('vertical-align') == 'middle', \
            button.value_of_css_property('vertical-align')
        assert button.value_of_css_property('text-transform') == 'uppercase', \
            button.value_of_css_property('text-transform')
        assert button.value_of_css_property('padding-top') == '6px', \
            button.value_of_css_property('padding-top')
        assert button.value_of_css_property('padding-bottom') == '6px', \
            button.value_of_css_property('padding-bottom')
        assert button.value_of_css_property('padding-left') == '12px', \
            button.value_of_css_property('padding-left')
        assert button.value_of_css_property('padding-right') == '12px', \
            button.value_of_css_property('padding-right')

    @staticmethod
    def validate_secondary_big_green_button_style(button):
        """
        Ensure consistency in rendering page and overlay big WHITE-backed, green text buttons across
          the application
        :param button: button to validate
        """
        assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
            button.value_of_css_property('font-family')
        # The upload sourcefile button of the upload ms card is allocated a 200px bounding box!
        # assert button.value_of_css_property('font-size') == '14px', \
        #    button.value_of_css_property('font-size')
        # APERTA-6498
        # assert button.value_of_css_property('line-height') == '18px', \
        #     button.value_of_css_property('line-height')
        assert button.value_of_css_property('color') == APERTA_GREEN, \
            button.value_of_css_property('color')
        # Disabling due to upload source file button misimplementation
        # assert button.value_of_css_property('background-color') == WHITE, \
        #     button.value_of_css_property('background-color')
        # assert button.value_of_css_property('vertical-align') == 'middle', \
        #     button.value_of_css_property('vertical-align')
        # assert button.value_of_css_property('text-transform') == 'uppercase', \
        #     button.value_of_css_property('text-transform')
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
        Ensure consistency in rendering page and overlay transparent-backed, green text
          link-buttons across the application
        :param button: button to validate
        """
        assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
            button.value_of_css_property('font-family')
        assert button.value_of_css_property('font-size') == '14px', \
            button.value_of_css_property('font-size')
        assert button.value_of_css_property('font-weight') == '400', \
            button.value_of_css_property('font-weight')
        assert button.value_of_css_property('line-height') == '20px', \
            button.value_of_css_property('line-height')
        assert button.value_of_css_property('color') == APERTA_GREEN, \
            button.value_of_css_property('color')
        assert button.value_of_css_property('background-color') == 'rgba(0, 0, 0, 0)', \
            button.value_of_css_property('background-color')
        assert button.value_of_css_property('text-align') == 'center', \
            button.value_of_css_property('text-align')
        assert button.value_of_css_property('vertical-align') == 'middle', \
            button.value_of_css_property('vertical-align')
        assert button.value_of_css_property('padding-top') == '6px', \
            button.value_of_css_property('padding-top')
        assert button.value_of_css_property('padding-bottom') == '6px', \
            button.value_of_css_property('padding-bottom')
        assert button.value_of_css_property('padding-left') == '12px', \
            button.value_of_css_property('padding-left')
        assert button.value_of_css_property('padding-right') == '12px', \
            button.value_of_css_property('padding-right')

    @staticmethod
    def validate_primary_small_green_button_style(button):
        """
        Ensure consistency in rendering page and overlay small green-backed, WHITE text buttons
          across the application
        :param button: button to validate
        """
        assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
            button.value_of_css_property('font-family')
        assert button.value_of_css_property('font-size') == '14px', \
            button.value_of_css_property('font-size')
        assert button.value_of_css_property('font-weight') == '400', \
            button.value_of_css_property('font-weight')
        assert button.value_of_css_property('line-height') == '20px', \
            button.value_of_css_property('line-height')
        assert button.value_of_css_property('color') == WHITE, \
            button.value_of_css_property('color')
        assert button.value_of_css_property('background-color') == APERTA_GREEN, \
            button.value_of_css_property('background-color')
        assert button.value_of_css_property('text-align') == 'center', \
            button.value_of_css_property('text-align')
        assert button.value_of_css_property('vertical-align') == 'middle', \
            button.value_of_css_property('vertical-align')
        assert button.value_of_css_property('text-transform') == 'uppercase', \
            button.value_of_css_property('text-transform')
        assert button.value_of_css_property('padding-top') == '1px', \
            button.value_of_css_property('padding-top')
        assert button.value_of_css_property('padding-bottom') == '1px', \
            button.value_of_css_property('padding-bottom')
        assert button.value_of_css_property('padding-left') == '5px', \
            button.value_of_css_property('padding-left')
        assert button.value_of_css_property('padding-right') == '5px', \
            button.value_of_css_property('padding-right')

    @staticmethod
    def validate_secondary_small_green_button_style(button):
        """
        Ensure consistency in rendering page and overlay small WHITE-backed, green text buttons
          across the application
        :param button: button to validate
        """
        assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
            button.value_of_css_property('font-family')
        assert button.value_of_css_property('font-size') == '14px', \
            button.value_of_css_property('font-size')
        assert button.value_of_css_property('font-weight') == '400', \
            button.value_of_css_property('font-weight')
        assert button.value_of_css_property('color') == APERTA_GREEN, \
            button.value_of_css_property('color')
        assert button.value_of_css_property('text-transform') == 'uppercase', \
            button.value_of_css_property('text-transform')
        assert button.value_of_css_property('line-height') == '20px', \
            button.value_of_css_property('line-height')
        assert button.value_of_css_property('text-align') == 'center', \
            button.value_of_css_property('text-align')
        assert button.value_of_css_property('vertical-align') == 'middle', \
            button.value_of_css_property('vertical-align')
        assert button.value_of_css_property('background-color') == WHITE, \
            button.value_of_css_property('background-color')
        assert button.value_of_css_property('padding-top') == '1px', \
            button.value_of_css_property('padding-top')
        assert button.value_of_css_property('padding-right') == '5px', \
            button.value_of_css_property('padding-right')
        assert button.value_of_css_property('padding-bottom') == '1px', \
            button.value_of_css_property('padding-bottom')
        assert button.value_of_css_property('padding-left') == '5px', \
            button.value_of_css_property('padding-left')

    @staticmethod
    def validate_secondary_small_green_button_task_style(button):
        """
        Ensure consistency in rendering page and overlay small WHITE-backed, green text validations
        buttons across the application
        :param button: button to validate
        """
        assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
            button.value_of_css_property('font-family')
        assert button.value_of_css_property('font-size') == '14px', \
            button.value_of_css_property('font-size')
        assert button.value_of_css_property('font-weight') == '400', \
            button.value_of_css_property('font-weight')
        assert button.value_of_css_property('color') == APERTA_GREEN, \
            button.value_of_css_property('color')
        assert button.value_of_css_property('line-height') == '20px', \
            button.value_of_css_property('line-height')
        assert button.value_of_css_property('text-align') == 'center', \
            button.value_of_css_property('text-align')
        assert button.value_of_css_property('vertical-align') == 'middle', \
            button.value_of_css_property('vertical-align')
        assert button.value_of_css_property('background-color') == WHITE, \
            button.value_of_css_property('background-color')
        assert button.value_of_css_property('padding-top') == '6px', \
            button.value_of_css_property('padding-top')
        assert button.value_of_css_property('padding-right') == '12px', \
            button.value_of_css_property('padding-right')
        assert button.value_of_css_property('padding-bottom') == '6px', \
            button.value_of_css_property('padding-bottom')
        assert button.value_of_css_property('padding-left') == '12px', \
            button.value_of_css_property('padding-left')

    @staticmethod
    def validate_link_small_green_button_style(button):
        """
        Ensure consistency in rendering page and overlay transparent-backed, green text
          link-buttons across the application
        :param button: button to validate
        """
        assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
            button.value_of_css_property('font-family')
        assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property(
            'font-size')
        assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property(
            'font-weight')
        assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property(
            'line-height')
        assert button.value_of_css_property('color') == APERTA_GREEN, button.value_of_css_property(
            'color')
        assert button.value_of_css_property('background-color') == 'transparent', \
            button.value_of_css_property('background-color')
        assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property(
            'text-align')
        assert button.value_of_css_property(
            'vertical-align') == 'middle', button.value_of_css_property('vertical-align')
        assert button.value_of_css_property('padding-top') == '1px', button.value_of_css_property(
            'padding-top')
        assert button.value_of_css_property('padding-bottom') == '5px'
        assert button.value_of_css_property('padding-left') == '1px'
        assert button.value_of_css_property('padding-right') == '5px', button.value_of_css_property(
            'padding-right')

    @staticmethod
    def validate_primary_big_disabled_button_style(button):
        """
        Ensure consistency in rendering page and overlay large grey-backed, lighter grey text
          disabled buttons across the application
        :param button: button to validate
        """
        assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
            button.value_of_css_property('font-family')
        assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property(
            'font-size')
        assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property(
            'font-weight')
        assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property(
            'line-height')
        assert button.value_of_css_property(
            'color') == APERTA_GREY_LIGHT, button.value_of_css_property('color')
        # This color is not represented in the tahi palette
        assert button.value_of_css_property('background-color') == 'rgba(238, 238, 238, 1)', \
            button.value_of_css_property('background-color')
        assert button.value_of_css_property(
            'vertical-align') == 'middle', button.value_of_css_property('vertical-align')
        assert button.value_of_css_property(
            'text-transform') == 'uppercase', button.value_of_css_property('text-transform')
        assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property(
            'padding-top')
        assert button.value_of_css_property(
            'padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
        assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property(
            'padding-left')
        assert button.value_of_css_property(
            'padding-right') == '12px', button.value_of_css_property('padding-right')

    @staticmethod
    def validate_secondary_big_disabled_button_style(button):
        """
        Ensure consistency in rendering page and overlay large WHITE-backed, grey text disabled
        buttons across the application
        :param button: button to validate
        """
        assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
            button.value_of_css_property('font-family')
        assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property(
            'font-size')
        assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property(
            'font-weight')
        assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property(
            'line-height')
        assert button.value_of_css_property(
            'color') == APERTA_GREY_LIGHT, button.value_of_css_property('color')
        assert button.value_of_css_property('background-color') == WHITE, \
            button.value_of_css_property('background-color')
        assert button.value_of_css_property(
            'vertical-align') == 'middle', button.value_of_css_property('vertical-align')
        assert button.value_of_css_property(
            'text-transform') == 'uppercase', button.value_of_css_property('text-transform')
        assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property(
            'padding-top')
        assert button.value_of_css_property(
            'padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
        assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property(
            'padding-left')
        assert button.value_of_css_property(
            'padding-right') == '12px', button.value_of_css_property('padding-right')

    @staticmethod
    def validate_link_big_disabled_button_style(button):
        """
        Ensure consistency in rendering page and overlay large transparent-backed, grey text
        disabled buttons across the application
        :param button: button to validate
        """
        assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
            button.value_of_css_property('font-family')
        assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property(
            'font-size')
        assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property(
            'font-weight')
        assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property(
            'line-height')
        assert button.value_of_css_property(
            'color') == APERTA_GREY_LIGHT, button.value_of_css_property('color')
        assert button.value_of_css_property('background-color') == 'transparent', \
            button.value_of_css_property('background-color')
        assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property(
            'text-align')
        assert button.value_of_css_property(
            'vertical-align') == 'middle', button.value_of_css_property('vertical-align')
        assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property(
            'padding-top')
        assert button.value_of_css_property(
            'padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
        assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property(
            'padding-left')
        assert button.value_of_css_property(
            'padding-right') == '12px', button.value_of_css_property('padding-right')

    @staticmethod
    def validate_green_on_green_button_style(button):
        """
        Ensure consistency in rendering page and overlay light green-backed, dark green text
          buttons across the application.
        These buttons should be used against a standard APERTA_GREEN background
        :param button: button to validate
        """
        assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
            button.value_of_css_property('font-family')
        assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property(
            'font-size')
        assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property(
            'font-weight')
        assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property(
            'line-height')
        assert button.value_of_css_property(
            'color') == APERTA_GREEN_DARK, button.value_of_css_property('color')
        assert button.value_of_css_property('background-color') == APERTA_GREEN_LIGHT, \
            button.value_of_css_property('background-color')
        assert button.value_of_css_property(
            'vertical-align') == 'middle', button.value_of_css_property('vertical-align')
        assert button.value_of_css_property(
            'text-transform') == 'uppercase', button.value_of_css_property('text-transform')
        assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property(
            'padding-top')
        assert button.value_of_css_property(
            'padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
        assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property(
            'padding-left')
        assert button.value_of_css_property(
            'padding-right') == '12px', button.value_of_css_property('padding-right')

    @staticmethod
    def validate_primary_big_grey_button_style(button):
        """
        Ensure consistency in rendering page and overlay large grey-backed, WHITE text buttons
        across the application
        TODO: Find out what the use case is for this design as it seems duplicative with the
        defined disabled buttons
        :param button: button to validate
        """
        assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
            button.value_of_css_property('font-family')
        assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property(
            'font-size')
        assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property(
            'font-weight')
        assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property(
            'line-height')
        assert button.value_of_css_property('color') == WHITE, button.value_of_css_property('color')
        # This color is not represented in the tahi palette
        assert button.value_of_css_property('background-color') == 'rgba(119, 119, 119, 1)', \
            button.value_of_css_property('background-color')
        assert button.value_of_css_property(
            'vertical-align') == 'middle', button.value_of_css_property('vertical-align')
        assert button.value_of_css_property(
            'text-transform') == 'uppercase', button.value_of_css_property('text-transform')
        assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property(
            'padding-top')
        assert button.value_of_css_property(
            'padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
        assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property(
            'padding-left')
        assert button.value_of_css_property(
            'padding-right') == '12px', button.value_of_css_property('padding-right')

    @staticmethod
    def validate_secondary_big_grey_button_style(button):
        """
        Ensure consistency in rendering page and overlay large WHITE-backed, grey text buttons
        across the application
        TODO: Find out what the use case is for this design as it seems duplicative with the
        defined disabled buttons
        :param button: button to validate
        """
        assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
            button.value_of_css_property('font-family')
        assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property(
            'font-size')
        assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property(
            'font-weight')
        assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property(
            'line-height')
        # This color is not represented in the tahi palette
        assert button.value_of_css_property(
            'color') == 'rgba(119, 119, 119, 1)', button.value_of_css_property('color')
        assert button.value_of_css_property('background-color') == WHITE, \
            button.value_of_css_property('background-color')
        assert button.value_of_css_property(
            'vertical-align') == 'middle', button.value_of_css_property('vertical-align')
        assert button.value_of_css_property(
            'text-transform') == 'uppercase', button.value_of_css_property('text-transform')
        assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property(
            'padding-top')
        assert button.value_of_css_property(
            'padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
        assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property(
            'padding-left')
        assert button.value_of_css_property(
            'padding-right') == '12px', button.value_of_css_property('padding-right')

    @staticmethod
    def validate_link_big_grey_button_style(button):
        """
        Ensure consistency in rendering page and overlay large transparent-backed, grey text
        buttons across the application
        TODO: Find out what the use case is for this design as it seems duplicative with the
        defined disabled buttons
        :param button: button to validate
        """
        assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
            button.value_of_css_property('font-family')
        assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property(
            'font-size')
        assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property(
            'font-weight')
        assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property(
            'line-height')
        # This color is not represented in the tahi palette
        assert button.value_of_css_property(
            'color') == APERTA_GREY_DARK, button.value_of_css_property('color')
        assert button.value_of_css_property('background-color') == TRANSPARENT, \
            button.value_of_css_property('background-color')
        assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property(
            'text-align')
        assert button.value_of_css_property(
            'vertical-align') == 'middle', button.value_of_css_property('vertical-align')
        assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property(
            'padding-top')
        assert button.value_of_css_property(
            'padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
        assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property(
            'padding-left')
        assert button.value_of_css_property(
            'padding-right') == '12px', button.value_of_css_property('padding-right')

    @staticmethod
    def validate_primary_small_grey_button_style(button):
        """
        Ensure consistency in rendering page and overlay small grey-backed, WHITE text buttons
        across the application
        TODO: Find out what the use case is for this design as it seems duplicative with the
        defined disabled buttons
        :param button: button to validate
        """
        assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
            button.value_of_css_property('font-family')
        assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property(
            'font-size')
        assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property(
            'font-weight')
        assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property(
            'line-height')
        assert button.value_of_css_property('color') == WHITE, button.value_of_css_property('color')
        # This color is not represented in the tahi palette
        assert button.value_of_css_property('background-color') == 'rgba(119, 119, 19, 1)', \
            button.value_of_css_property('background-color')
        assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property(
            'text-align')
        assert button.value_of_css_property(
            'vertical-align') == 'middle', button.value_of_css_property('vertical-align')
        assert button.value_of_css_property(
            'text-transform') == 'uppercase', button.value_of_css_property('text-transform')
        assert button.value_of_css_property('padding-top') == '1px', button.value_of_css_property(
            'padding-top')
        assert button.value_of_css_property(
            'padding-bottom') == '1px', button.value_of_css_property('padding-bottom')
        assert button.value_of_css_property('padding-left') == '5px', button.value_of_css_property(
            'padding-left')
        assert button.value_of_css_property('padding-right') == '5px', button.value_of_css_property(
            'padding-right')

    @staticmethod
    def validate_secondary_small_grey_button_style(button):
        """
        Ensure consistency in rendering page and overlay small WHITE-backed, grey text buttons
        across the application
        TODO: Find out what the use case is for this design as it seems duplicative with the
        defined disabled buttons
        :param button: button to validate
        """
        assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
            button.value_of_css_property('font-family')
        assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property(
            'font-size')
        assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property(
            'font-weight')
        # This color is not represented in the tahi palette
        assert button.value_of_css_property(
            'color') == 'rgba(119, 119, 119, 1)', button.value_of_css_property('color')
        assert button.value_of_css_property(
            'text-transform') == 'uppercase', button.value_of_css_property('text-transform')
        assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property(
            'line-height')
        assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property(
            'text-align')
        assert button.value_of_css_property(
            'vertical-align') == 'middle', button.value_of_css_property('vertical-align')
        assert button.value_of_css_property('background-color') == WHITE, \
            button.value_of_css_property('background-color')
        assert button.value_of_css_property('padding-top') == '1px', button.value_of_css_property(
            'padding-top')
        assert button.value_of_css_property('padding-right') == '5px', button.value_of_css_property(
            'padding-right')
        assert button.value_of_css_property(
            'padding-bottom') == '1px', button.value_of_css_property('padding-bottom')
        assert button.value_of_css_property('padding-left') == '5px', button.value_of_css_property(
            'padding-left')

    @staticmethod
    def validate_link_small_grey_button_style(button):
        """
        Ensure consistency in rendering page and overlay small transparent-backed, grey text
        link-buttons across the application
        TODO: Find out what the use case is for this design as it seems duplicative with the
        defined disabled buttons
        :param button: button to validate
        """
        assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
            button.value_of_css_property('font-family')
        assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property(
            'font-size')
        assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property(
            'font-weight')
        assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property(
            'line-height')
        # This color is not represented in the tahi palette
        assert button.value_of_css_property(
            'color') == 'rgba(119, 119, 119, 1)', button.value_of_css_property('color')
        assert button.value_of_css_property('background-color') == 'transparent', \
            button.value_of_css_property('background-color')
        assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property(
            'text-align')
        assert button.value_of_css_property(
            'vertical-align') == 'middle', button.value_of_css_property('vertical-align')
        assert button.value_of_css_property('padding-top') == '1px', button.value_of_css_property(
            'padding-top')
        assert button.value_of_css_property('padding-left') == '5px', button.value_of_css_property(
            'padding-left')
        assert button.value_of_css_property(
            'padding-bottom') == '1px', button.value_of_css_property('padding-bottom')
        assert button.value_of_css_property('padding-right') == '5px', button.value_of_css_property(
            'padding-right')

    @staticmethod
    def validate_grey_on_grey_button_style(button):
        """
        Ensure consistency in rendering page and overlay light grey-backed, dark-grey text buttons
        across the application
        These should be used on a standard tahi_grey background only.
        :param button: button to validate
        """
        assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
            button.value_of_css_property('font-family')
        assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property(
            'font-size')
        assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property(
            'font-weight')
        assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property(
            'line-height')
        assert button.value_of_css_property(
            'color') == APERTA_GREY_DARK, button.value_of_css_property('color')
        assert button.value_of_css_property('background-color') == APERTA_GREY_LIGHT, \
            button.value_of_css_property('background-color')
        assert button.value_of_css_property(
            'vertical-align') == 'middle', button.value_of_css_property('vertical-align')
        assert button.value_of_css_property(
            'text-transform') == 'uppercase', button.value_of_css_property('text-transform')
        assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property(
            'padding-top')
        assert button.value_of_css_property(
            'padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
        assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property(
            'padding-left')
        assert button.value_of_css_property(
            'padding-right') == '12px', button.value_of_css_property('padding-right')

    @staticmethod
    def validate_primary_big_blue_button_style(button):
        """
        Ensure consistency in rendering page and overlay large blue-backed, WHITE text buttons
        across the application
        :param button: button to validate
        """
        assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
            button.value_of_css_property('font-family')
        assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property(
            'font-size')
        assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property(
            'font-weight')
        assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property(
            'line-height')
        assert button.value_of_css_property('color') == WHITE, button.value_of_css_property('color')
        assert button.value_of_css_property('background-color') == APERTA_BLUE, \
            button.value_of_css_property('background-color')
        assert button.value_of_css_property(
            'vertical-align') == 'middle', button.value_of_css_property('vertical-align')
        assert button.value_of_css_property(
            'text-transform') == 'uppercase', button.value_of_css_property('text-transform')
        assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property(
            'padding-top')
        assert button.value_of_css_property(
            'padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
        assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property(
            'padding-left')
        assert button.value_of_css_property(
            'padding-right') == '12px', button.value_of_css_property('padding-right')

    @staticmethod
    def validate_secondary_big_blue_button_style(button):
        """
        Ensure consistency in rendering page and overlay large WHITE-backed, blue text buttons
        across the application
        :param button: button to validate
        """
        assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
            button.value_of_css_property('font-family')
        assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property(
            'font-size')
        assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property(
            'font-weight')
        assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property(
            'line-height')
        assert button.value_of_css_property('color') == APERTA_BLUE, button.value_of_css_property(
            'color')
        assert button.value_of_css_property('background-color') == WHITE, \
            button.value_of_css_property('background-color')
        assert button.value_of_css_property(
            'vertical-align') == 'middle', button.value_of_css_property('vertical-align')
        assert button.value_of_css_property(
            'text-transform') == 'uppercase', button.value_of_css_property('text-transform')
        assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property(
            'padding-top')
        assert button.value_of_css_property(
            'padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
        assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property(
            'padding-left')
        assert button.value_of_css_property(
            'padding-right') == '12px', button.value_of_css_property('padding-right')

    @staticmethod
    def validate_link_big_blue_button_style(button):
        """
        Ensure consistency in rendering page and overlay large transparent-backed, blue text
        buttons across the application
        :param button: button to validate
        """
        assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
            button.value_of_css_property('font-family')
        assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property(
            'font-size')
        assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property(
            'font-weight')
        assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property(
            'line-height')
        assert button.value_of_css_property('color') == APERTA_BLUE, button.value_of_css_property(
            'color')
        assert button.value_of_css_property('background-color') == 'transparent', \
            button.value_of_css_property('background-color')
        assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property(
            'text-align')
        assert button.value_of_css_property(
            'vertical-align') == 'middle', button.value_of_css_property('vertical-align')
        assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property(
            'padding-top')
        assert button.value_of_css_property(
            'padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
        assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property(
            'padding-left')
        assert button.value_of_css_property(
            'padding-right') == '12px', button.value_of_css_property('padding-right')

    @staticmethod
    def validate_primary_small_blue_button_style(button):
        """
        Ensure consistency in rendering page and overlay small blue-backed, WHITE text buttons
        across the application
        :param button: button to validate
        """
        assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
            button.value_of_css_property('font-family')
        assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property(
            'font-size')
        assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property(
            'font-weight')
        assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property(
            'line-height')
        assert button.value_of_css_property('color') == WHITE, button.value_of_css_property('color')
        assert button.value_of_css_property('background-color') == APERTA_BLUE, \
            button.value_of_css_property('background-color')
        assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property(
            'text-align')
        assert button.value_of_css_property(
            'vertical-align') == 'middle', button.value_of_css_property('vertical-align')
        assert button.value_of_css_property(
            'text-transform') == 'uppercase', button.value_of_css_property('text-transform')
        assert button.value_of_css_property('padding-top') == '1px', button.value_of_css_property(
            'padding-top')
        assert button.value_of_css_property(
            'padding-bottom') == '1px', button.value_of_css_property('padding-bottom')
        assert button.value_of_css_property('padding-left') == '5px', button.value_of_css_property(
            'padding-left')
        assert button.value_of_css_property('padding-right') == '5px', button.value_of_css_property(
            'padding-right')

    @staticmethod
    def validate_secondary_small_blue_button_style(button):
        """
        Ensure consistency in rendering page and overlay small WHITE-backed, blue text buttons
        across the application
        :param button: button to validate
        """
        assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
            button.value_of_css_property('font-family')
        assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property(
            'font-size')
        assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property(
            'font-weight')
        assert button.value_of_css_property('color') == APERTA_BLUE, button.value_of_css_property(
            'color')
        assert button.value_of_css_property(
            'text-transform') == 'uppercase', button.value_of_css_property('text-transform')
        assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property(
            'line-height')
        assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property(
            'text-align')
        assert button.value_of_css_property(
            'vertical-align') == 'middle', button.value_of_css_property('vertical-align')
        assert button.value_of_css_property('background-color') == WHITE, \
            button.value_of_css_property('background-color')
        assert button.value_of_css_property('padding-top') == '1px', button.value_of_css_property(
            'padding-top')
        assert button.value_of_css_property('padding-right') == '5px', button.value_of_css_property(
            'padding-right')
        assert button.value_of_css_property(
            'padding-bottom') == '1px', button.value_of_css_property('padding-bottom')
        assert button.value_of_css_property('padding-left') == '5px', button.value_of_css_property(
            'padding-left')

    @staticmethod
    def validate_link_small_blue_button_style(button):
        """
        Ensure consistency in rendering page and overlay small transparent-backed, blue text
        link-buttons across the application
        :param button: button to validate
        """
        assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
            button.value_of_css_property('font-family')
        assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property(
            'font-size')
        assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property(
            'font-weight')
        assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property(
            'line-height')
        assert button.value_of_css_property('color') == APERTA_BLUE, button.value_of_css_property(
            'color')
        assert button.value_of_css_property('background-color') == 'transparent', \
            button.value_of_css_property('background-color')
        assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property(
            'text-align')
        assert button.value_of_css_property(
            'vertical-align') == 'middle', button.value_of_css_property('vertical-align')
        assert button.value_of_css_property('padding-top') == '1px', button.value_of_css_property(
            'padding-top')
        assert button.value_of_css_property('padding-left') == '5px', button.value_of_css_property(
            'padding-left')
        assert button.value_of_css_property(
            'padding-bottom') == '1px', button.value_of_css_property('padding-bottom')
        assert button.value_of_css_property('padding-right') == '5px', button.value_of_css_property(
            'padding-right')

    @staticmethod
    def validate_blue_on_blue_button_style(button):
        """
        Ensure consistency in rendering page and overlay light blue-backed, dark-blue text buttons
        across the application
        These should only be used against a standard APERTA_BLUE background
        :param button: button to validate
        """
        assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
            button.value_of_css_property('font-family')
        assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property(
            'font-size')
        assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property(
            'font-weight')
        assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property(
            'line-height')
        assert button.value_of_css_property('color') == APERTA_BLUE, button.value_of_css_property(
            'color')
        assert button.value_of_css_property('background-color') == WHITE, \
            button.value_of_css_property('background-color')
        assert button.value_of_css_property(
            'vertical-align') == 'middle', button.value_of_css_property('vertical-align')
        assert button.value_of_css_property(
            'text-transform') == 'uppercase', button.value_of_css_property('text-transform')
        assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property(
            'padding-top')
        assert button.value_of_css_property(
            'padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
        assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property(
            'padding-left')
        assert button.value_of_css_property(
            'padding-right') == '12px', button.value_of_css_property('padding-right')

    @staticmethod
    def validate_primary_error_button_style(button):
        """
        Ensure consistency in rendering page and overlay validation failed WHITE background buttons
        across the application
        :param button: button to validate
        """
        assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family'), \
            button.value_of_css_property('font-family')
        assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property(
            'font-size')
        assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property(
            'font-weight')
        assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property(
            'line-height')
        assert button.value_of_css_property('color') == APERTA_ERROR, button.value_of_css_property(
            'color')
        assert button.value_of_css_property('background-color') == WHITE, \
            button.value_of_css_property('background-color')
        assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property(
            'text-align')
        assert button.value_of_css_property(
            'vertical-align') == 'middle', button.value_of_css_property('vertical-align')
        assert button.value_of_css_property(
            'text-transform') == 'uppercase', button.value_of_css_property('text-transform')
        assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property(
            'padding-top')
        assert button.value_of_css_property(
            'padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
        assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property(
            'padding-left')
        assert button.value_of_css_property(
            'padding-right') == '12px', button.value_of_css_property('padding-right')

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
        assert field.value_of_css_property('color') == 'rgb(85, 85, 85)', \
            field.value_of_css_property('color')
        assert field.value_of_css_property('line-height') == '20px', \
            field.value_of_css_property('line-height')

    @staticmethod
    def validate_input_field_inside_label_style(label):
        """
        Ensure consistency in rendering page, card and overlay internal input field labels
          across the application
        :param label: label to validate
        NOTE: Updated 20160722 as per style guide at:
        https://app.zeplin.io/project.html#pid=560d7bb83705520f4c7c0524&sid=56b239c60e93fc526ca02f8f
        """
        assert APPLICATION_TYPEFACE in label.value_of_css_property('font-family')
        assert label.value_of_css_property('font-size') == '14px', \
            label.value_of_css_property('font-size')
        assert label.value_of_css_property('color') == APERTA_GREY_DARK, \
            label.value_of_css_property('color')

    @staticmethod
    def validate_input_field_external_label_style(label):
        """
        Ensure consistency in the rendering of page, card and overlay external input field labels
            across the application
        :param label: label to validate
        NOTE: This is now inconsistently defined in the v1.1 style guide - we specify 12px in the
            typography section but 14px in the examples section. Speaking with Sam V. 14px is the
            correct value.
        """
        assert APPLICATION_TYPEFACE in label.value_of_css_property('font-family'), \
            label.value_of_css_property('font-family')
        assert label.value_of_css_property('font-size') == '14px', \
            label.value_of_css_property('font-size')
        assert label.value_of_css_property('color') == APERTA_BLACK, \
            label.value_of_css_property('color')

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
        assert field.value_of_css_property('padding-right') == '12px', \
            field.value_of_css_property('padding-left')

    @staticmethod
    def validate_multi_select_dropdown_style(field):
        """
        Ensure consistency in rendering page, card and overlay multi-select drop down fields
          across the application
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
        Ensure consistency in rendering page, card and overlay textarea fields across the
          application
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
        Ensure consistency in rendering page, card and overlay radio buttons across the
          application
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
        # assert button.value_of_css_property('color') == BLACK,
        # button.value_of_css_property('color')
        assert button.value_of_css_property('line-height') == '18px', \
            button.value_of_css_property('line-height')

    @staticmethod
    def validate_radio_button_label(label):
        """
        Ensure consistency in rendering page, card and overlay radio button labels across
          the application
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
        Ensure consistency in rendering page, card and overlay checkbox labels across
          the application
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
        assert field.value_of_css_property('color') == 'rgba(208, 2, 27, 1)', \
            field.value_of_css_property('color')
        assert field.value_of_css_property('font-size') == '14px', \
            field.value_of_css_property('font-size')
        assert field.value_of_css_property('line-height') == '20px', \
            field.value_of_css_property('line-height')

    @staticmethod
    def validate_rescind_decision_success_style(msg):
        """
        Ensure consistency in rendering success alerts for rescind decision elements
        :param msg: alert message to validate
        """
        assert APPLICATION_TYPEFACE in msg.value_of_css_property('font-family'), \
            msg.value_of_css_property('font-family')
        assert msg.value_of_css_property('font-size') == '14px', msg.value_of_css_property(
            'font-size')
        # This color is not represented in the tahi palette
        assert msg.value_of_css_property('color') == APERTA_BLACK, \
            msg.value_of_css_property('color')
        assert msg.value_of_css_property('line-height') == '20px', \
            msg.value_of_css_property('line-height')

    @staticmethod
    def validate_rescind_decision_info_style(msg):
        """
        Ensure consistency in rendering informational alerts for rescind decision elements
        :param msg: alert message to validate
        """
        assert APPLICATION_TYPEFACE in msg.value_of_css_property('font-family'), \
            msg.value_of_css_property('font-family')
        assert msg.value_of_css_property('font-size') == '18px', msg.value_of_css_property(
            'font-size')
        # This color is not represented in the tahi palette
        assert msg.value_of_css_property('color') == APERTA_BLACK, \
            msg.value_of_css_property('color')
        assert msg.value_of_css_property('background-color') == APERTA_GREY_XLIGHT, \
            msg.value_of_css_property('background-color')
        assert msg.value_of_css_property('line-height') == '19.8px', \
            msg.value_of_css_property('line-height')

    @staticmethod
    def validate_rescind_decision_info_revision_style(msg):
        """
        Ensure consistency in rendering revision information in informational alerts for rescind
          decision elements
        :param msg: alert message to validate
        """
        assert APPLICATION_TYPEFACE in msg.value_of_css_property('font-family'), \
            msg.value_of_css_property('font-family')
        assert msg.value_of_css_property('font-size') == '18px', msg.value_of_css_property(
            'font-size')
        assert msg.value_of_css_property('color') == APERTA_BLACK, \
            msg.value_of_css_property('color')
        assert msg.value_of_css_property('line-height') == '19.8px', \
            msg.value_of_css_property('line-height')
        assert msg.value_of_css_property('font-weight') == 700, msg.value_of_css_property(
            'font-weight')

    @staticmethod
    def validate_rescind_decision_info_rescinded_flag(msg):
        """
        Ensure consistency in rendering rescinded information in informational alerts for rescind
          decision elements
        :param msg: alert message to validate
        """
        assert APPLICATION_TYPEFACE in msg.value_of_css_property('font-family'), \
            msg.value_of_css_property('font-family')
        assert msg.value_of_css_property('font-size') == '14px', msg.value_of_css_property(
            'font-size')
        # This color is not represented in the tahi palette
        assert msg.value_of_css_property('color') == APERTA_BLACK, \
            msg.value_of_css_property('color')
        assert msg.value_of_css_property('background-color') == 'rgba(108, 108, 108, 1)', \
            msg.value_of_css_property('background-color')
        assert msg.value_of_css_property('line-height') == '19.8px', \
            msg.value_of_css_property('line-height')
        assert msg.value_of_css_property('font-weight') == 700, msg.value_of_css_property(
            'font-weight')

    @staticmethod
    def validate_warning_message_style(warning, message):
        """
        Ensure consistency in rendering warning across confirmation
        :param warning: Warning element
        :param message: string, message to validate warning text
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
        assert avatar.value_of_css_property('font-size') == '14px', avatar.value_of_css_property(
            'font-size')
        # These colors are not represented in the style guide
        assert avatar.value_of_css_property('color') == APERTA_BLACK, avatar.value_of_css_property(
            'color')
        assert avatar.value_of_css_property('line-height') == '20px', avatar.value_of_css_property(
            'line-height')
        assert avatar.value_of_css_property(
            'vertical-align') == 'middle', avatar.value_of_css_property('vertical-align')
        assert avatar.value_of_css_property('width') == '160px', avatar.value_of_css_property(
            'width')
        assert avatar.value_of_css_property('height') == '160px', avatar.value_of_css_property(
            'height')

    @staticmethod
    def validate_large_avatar_hover_style(avatar):
        """
        Ensure consistency in rendering large avatar hover states across the application
        :param avatar: avatar to validate
        """
        assert APPLICATION_TYPEFACE in avatar.value_of_css_property('font-family'), \
            avatar.value_of_css_property('font-family')
        assert avatar.value_of_css_property('font-size') == '14px', avatar.value_of_css_property(
            'font-size')
        # This color is not represented in the style guide
        assert avatar.value_of_css_property(
            'color') == APERTA_GREEN_DARK, avatar.value_of_css_property('color')
        assert avatar.value_of_css_property('background-color') == APERTA_GREEN_LIGHT, \
            avatar.value_of_css_property('background-color')
        assert avatar.value_of_css_property('line-height') == '20px', avatar.value_of_css_property(
            'line-height')
        assert avatar.value_of_css_property(
            'vertical-align') == 'middle', avatar.value_of_css_property('vertical-align')

    @staticmethod
    def validate_thumbnail_avatar_style(avatar):
        """
        Ensure consistency in rendering thumbnail avatars across the application
        :param avatar: avatar to validate
        """
        assert APPLICATION_TYPEFACE in avatar.value_of_css_property('font-family'), \
            avatar.value_of_css_property('font-family')
        assert avatar.value_of_css_property('font-size') == '14px', avatar.value_of_css_property(
            'font-size')
        # These colors are not represented in the style guide
        assert avatar.value_of_css_property('color') == APERTA_BLACK, avatar.value_of_css_property(
            'color')
        assert avatar.value_of_css_property('line-height') == '20px', avatar.value_of_css_property(
            'line-height')
        assert avatar.value_of_css_property(
            'vertical-align') == 'middle', avatar.value_of_css_property('vertical-align')
        assert avatar.value_of_css_property('width') == '32px', avatar.value_of_css_property(
            'width')
        assert avatar.value_of_css_property('height') == '32px', avatar.value_of_css_property(
            'height')

    @staticmethod
    def validate_small_thumbnail_avatar_style(avatar):
        """
        Ensure consistency in rendering thumbnail avatars across the application
        :param avatar: avatar to validate
        """
        assert APPLICATION_TYPEFACE in avatar.value_of_css_property('font-family'), \
            avatar.value_of_css_property('font-family')
        assert avatar.value_of_css_property('font-size') == '14px', avatar.value_of_css_property(
            'font-size')
        # These colors are not represented in the style guide
        assert avatar.value_of_css_property('color') == APERTA_BLACK, avatar.value_of_css_property(
            'color')
        assert avatar.value_of_css_property('line-height') == '20px', avatar.value_of_css_property(
            'line-height')
        assert avatar.value_of_css_property(
            'vertical-align') == 'middle', avatar.value_of_css_property('vertical-align')
        assert avatar.value_of_css_property('width') == '25px', avatar.value_of_css_property(
            'width')
        assert avatar.value_of_css_property('height') == '25px', avatar.value_of_css_property(
            'height')

    # Activity Overlay Styles ==================
    # Why does this one overlay get it's own styles?
    @staticmethod
    def validate_activity_message_style(msg):
        """
        Ensure consistency in rendering activity list messages
        :param msg: activity message to validate
        """
        assert APPLICATION_TYPEFACE in msg.value_of_css_property(
            'font-size'), msg.value_of_css_property('font-size')
        assert msg.value_of_css_property('font-size') == '17px', msg.value_of_css_property(
            'font-size')
        # This color is not represented in the style guide
        assert msg.value_of_css_property('line-height') == APERTA_BLACK, msg.value_of_css_property(
            'line-height')
        assert msg.value_of_css_property('line-height') == '24.2833px', msg.value_of_css_property(
            'line-height')
        assert msg.value_of_css_property('padding-top') == '0px', msg.value_of_css_property(
            'padding-top')
        assert msg.value_of_css_property('padding-right') == '15px', msg.value_of_css_property(
            'padding-right')
        assert msg.value_of_css_property('padding-bottom') == '25px', msg.value_of_css_property(
            'padding-bottom')
        assert msg.value_of_css_property('padding-left') == '0px', msg.value_of_css_property(
            'padding-left')

    @staticmethod
    def validate_activity_timestamp_style(timestamp):
        """
        Ensure consistency in rendering activity list timestamps
        :param timestamp: timestamp to validate
        """
        assert APPLICATION_TYPEFACE in timestamp.value_of_css_property('font-size'), \
            timestamp.value_of_css_property('font-size')
        assert timestamp.value_of_css_property(
            'font-size') == '14px', timestamp.value_of_css_property('font-size')
        # This color is not represented in the style guide
        assert timestamp.value_of_css_property('line-height') == APERTA_BLACK, \
            timestamp.value_of_css_property('line-height')
        assert timestamp.value_of_css_property(
            'line-height') == '20px', timestamp.value_of_css_property('line-height')
        assert timestamp.value_of_css_property(
            'padding-top') == '0px', timestamp.value_of_css_property('padding-top')
        assert timestamp.value_of_css_property(
            'padding-right') == '15px', timestamp.value_of_css_property('padding-right')
        assert timestamp.value_of_css_property('padding-bottom') == '25px', \
            timestamp.value_of_css_property('padding-bottom')
        assert timestamp.value_of_css_property(
            'padding-left') == '0px', timestamp.value_of_css_property('padding-left')

    # Progress Styles ==========================
    @staticmethod
    def validate_progress_spinner_style(spinner):
        """
        Ensure consistency in rendering progress spinners across the application
        :param spinner: spinner to validate
        """
        assert APPLICATION_TYPEFACE in spinner.value_of_css_property('font-family'), \
            spinner.value_of_css_property('font-family')
        assert spinner.value_of_css_property('font-size') == '14px', spinner.value_of_css_property(
            'font-size')
        # These colors are not represented in the style guide
        assert spinner.value_of_css_property(
            'color') == APERTA_BLACK, spinner.value_of_css_property('color')
        assert spinner.value_of_css_property(
            'line-height') == '20px', spinner.value_of_css_property('line-height')
        assert spinner.value_of_css_property('width') == '50px', spinner.value_of_css_property(
            'width')
        assert spinner.value_of_css_property('height') == '50px', spinner.value_of_css_property(
            'height')

    @staticmethod
    def validate_file_title_style(ft):
        """
        Ensure consistency in rendering the file title in SI Card
        :param ft: File title to validate
        """
        assert APPLICATION_TYPEFACE in ft.value_of_css_property('font-family'), \
            ft.value_of_css_property('font-family')
        assert ft.value_of_css_property('font-size') == '14px', ft.value_of_css_property(
            'font-size')
        assert ft.value_of_css_property('font-weight') == '700', \
            ft.value_of_css_property('font-weight')
        assert ft.value_of_css_property('line-height') == '20px', \
            ft.value_of_css_property('line-height')
        # This color is not represented in the tahi palette
        assert ft.value_of_css_property('color') == APERTA_BLACK, ft.value_of_css_property('color')

    @staticmethod
    def validate_cancel_button_style(button):
        assert APPLICATION_TYPEFACE in button.value_of_css_property('font-family')
        assert button.value_of_css_property('font-size') == '14px'
        assert button.value_of_css_property('line-height') == '60px'
        assert button.value_of_css_property('background-color') == TRANSPARENT
        assert button.value_of_css_property('color') == APERTA_GREEN
        assert button.value_of_css_property('font-weight') == '400'
        # TODO: Styles for create_new_topic since is not in the style guide

    # Diffing/Versioning Styles =====================
    # The following three styles are not present in the style guide but were reviewed by Sam on
    #     20180117
    @staticmethod
    def validate_diff_redaction_style(element):
        """
        Validate the redaction style of card versions view - note this only validates
        the strike-through and background color
        :param element: a element against which to evaluate style
        :return: void function
        """
        assert element.value_of_css_property('background-color') == 'rgba(253, 219, 223, 0.5)', \
            element.value_of_css_property('background-color')
        assert element.value_of_css_property('text-decoration') == 'line-through', \
            element.value_of_css_property('text-decoration')

    @staticmethod
    def validate_diff_addition_style(element):
        """
        Validate the addition style of card versions view - note this only validates
        the background color
        :param element: a element against which to evaluate style
        :return: void function
        """
        assert element.value_of_css_property('background-color') == 'rgba(142, 203, 135, 0.5)', \
            element.value_of_css_property('background-color')

    @staticmethod
    def validate_diff_no_change_style(element):
        """
        Validate the no difference style of card versions view - note this only validates
        the color
        :param element: a element against which to evaluate style
        :return: void function
        """
        assert element.value_of_css_property('color') == 'rgba(135, 135, 135, 0)', \
            element.value_of_css_property('color')
