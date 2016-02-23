#!/usr/bin/env python2

__author__ = 'jkrzemien@plos.org'

from datetime import datetime
from time import time
from inspect import getfile
from os.path import abspath, dirname

from selenium.webdriver.support.events import AbstractEventListener
from selenium.common.exceptions import NoSuchElementException, WebDriverException

from Base.CustomException import ElementDoesNotExistAssertionError

LOG_HEADER = '\t[WebDriver %s] '

class WebDriverListener(AbstractEventListener):
  """
  WebDriver's listener for printing out information to STDOUT whenever the driver is about to/done
  processing an event.

  These events are triggered from the EventFiringWebDriver instance before and after each
  available action on the driver's intance.
  """

  # Just a mapping between HTML tag names and their 'human readable' form, for the logger
  _pretty_names = {
    'a': 'link',
    'img': 'image',
    'button': 'button',
    'input': 'text box',
    'textarea': 'text area',
    'submit': 'button',
    'cancel': 'button',
    'select': 'drop down box',
    'option': 'drop down option',
    'radio': 'radio button',
    'li': 'list item'
  }

  # Constructor. Initializes parent class (`AbstractEventListener`)
  def __init__(self):
    super(WebDriverListener, self).__init__()
    self._driver = None

  def after_click(self, element, driver):
    self._log('Click on "%s" %s successful' % self.lastElement)

  def after_find(self, by, value, driver):
    self._log('Element "%s" identified successfully' % value)

  def before_click(self, element, driver):
    friendly_name = self._friendly_tag_name(element)
    self.lastElement = (self._tidyText(element.text), friendly_name)
    self._log('Clicking on "%s" %s...' % self.lastElement)

  def before_find(self, by, value, driver):
    if self._driver is None:
      self._driver = driver
    message = 'Identifing element using "%s" as locator (%s strategy)...' % (value, str(by))
    self._log(message)

  def before_navigate_back(self, driver):
    self._log('Navigating back to previous page...')

  def before_navigate_to(self, url, driver):
    if self._driver is None:
      self._driver = driver
    print '=' * 80
    self._log('Navigating to %s...' % url)

  def on_exception(self, exception, driver):
    if type(exception) in [NoSuchElementException,
                           ElementDoesNotExistAssertionError,
                           AssertionError,
                           WebDriverException]:
      self._log('The locator provided did not match any element in the page. %s' % exception.msg)
    driver.save_screenshot(self._generate_png_filename(exception))

  def _generate_png_filename(self, exception):
    """
    Helper *internal* method to generate a filaname for the captured screenshots
    """
    ts = time()
    timestamp = datetime.fromtimestamp(ts).strftime('%Y%m%d-%H%M%S')
    path = dirname(abspath(getfile(WebDriverListener)))
    print('Saving screenshot: ')
    print(exception.__class__.__name__ + '-' + timestamp + '.png')
    return '%s/../Output/%s-%s.png' % (path, exception.__class__.__name__, timestamp)

  def _friendly_tag_name(self, element):
    """
    Helper *internal* method to "translate" some keywords to human readable ones before printing out messages
    """
    try:
      name = WebDriverListener._pretty_names[element.tag_name]
    except KeyError:
      try:
        name = WebDriverListener._pretty_names[element.get_attribute("type")]
      except KeyError:
        name = ""
    return name

  def _log(self, msg):
    """
    Helper *internal* method to print out messages from this listener
    """
    d = dict(self._driver.capabilities)
    print ''
    print LOG_HEADER % d['browserName'],
    print msg

  def _tidyText(self, text):
    """
    Helper *internal* method to remove some annoying characters before printing out messages
    """
    if (text is not None):
      text = text.strip()
      text = text.replace('\t', ' ')
      text = text.replace('\n', ' ')
      text = text.replace('\v', ' ')
      while text.count('  ') > 0:
        text = text.replace('  ', ' ')
      return text
    return ''

  # Not implemented
  def after_change_value_of(self, element, driver):
    pass

  # Not implemented
  def after_close(self, driver):
    pass

  # Not implemented
  def after_execute_script(self, script, driver):
    pass

  # Not implemented
  def after_navigate_back(self, driver):
    pass

  # Not implemented
  def after_navigate_forward(self, driver):
    pass

  # Not implemented
  def after_navigate_to(self, url, driver):
    pass

  # Not implemented
  def after_quit(self, driver):
    pass

  # Not implemented
  def before_change_value_of(self, element, driver):
    pass

  # Not implemented
  def before_close(self, driver):
    pass

  # Not implemented
  def before_execute_script(self, script, driver):
    pass

  # Not implemented
  def before_navigate_forward(self, driver):
    pass

  # Not implemented
  def before_quit(self, driver):
    pass
