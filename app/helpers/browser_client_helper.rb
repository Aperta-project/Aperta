# helper that handles browser concerns - uses browser gem (https://github.com/fnando/browser)
module BrowserClientHelper
  def unsupported_browser
    # The 'browser' gem assumes IE9 as modern, but we care about IE10 and above
    !browser.modern? || (browser.ie? && browser.version.to_i <= 10)
  end
end
