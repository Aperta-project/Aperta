#!/usr/bin/env python2

__author__ = 'jkrzemien@plos.org'

import requests
from requests.exceptions import HTTPError, Timeout
from socket import error as SocketError
from time import sleep
import Config as Config


class LinkVerifier(object):

  """

  This class is in charge of validating a link is up and running (HTTP OK)

  Facilitates:

    1. *Caching* of previously verified links.
    2. *Retries* for failed links.

  The reason why I had to make a simple task (such as pinging an URL to see
  if it is alive) this convoluted was because PLoS integrated environment's
  links point to *production* sites and they seem to have some kind of *Throttling*
  feature on it.

  Point being, validating 100s of links quickly result in **TIME OUTs** from servers,
  but if we wait a little bit between pings and retry again the link seems to work fine.

  This class can be configured by the following settings:

  1. `verify_link_timeout` [[Config.py#verify_link_timeout]]
  2. `verify_link_retries` [[Config.py#verify_link_retries]]
  3. `wait_between_retries` [[Config.py#wait_between_retries]]

  """

  cache = {}
  timeout = Config.verify_link_timeout
  max_retries = Config.verify_link_retries
  wait_between_retries = Config.wait_between_retries

  def __verify_link(self, url):
    successful = False
    attempts = 1
    while not successful and attempts < self.max_retries:
      try:
        response = requests.get(url, timeout=self.timeout, allow_redirects=True, verify=False)
        code = response.status_code
        successful = True
      except Timeout:
        code = "TIMED OUT"
        attempts += 1
        sleep(self.wait_between_retries)
    return code

  def is_link_valid(self, link):
    try:
      # Cache HIT
      code = self.cache[link]
    except KeyError:
      # Cache MISS
      try:
        code = self.__verify_link(link)
        # Save into cache
        self.cache[link] = code
      except HTTPError as e:
        code = e.code
      except SocketError as e:
        code = e.errno # Probably an ECONNRESET...
        print "Socket error: %s" % code

    print "HTTP %s" % code
    assert code == 200, "Expected HTTP response code was 200 (OK), but instead I got: %s" % code
    return True