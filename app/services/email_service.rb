# This service handles various email validation and
# normalizationtasks throughout our app
class EmailService
  AT_SYMBOL = /.+@.+/
  ANGLE_ADDR = /
                (?:.+<)     # name and open angle bracket
                ([^>]+)     # the actual email address (addr-spec)
                (?:>)       # closing bracket
               /x
  def initialize(email:)
    @email = email
  end

  # This normalizes emails to addr-spec
  #
  # we currently receive emails that take the form of an
  #   * addr-spec (what we want)
  #   * angle-addr = [CFWS] "<" addr-spec ">" [CFWS] / obs-angle-addr
  # this setter will normalize angle-addr to addr-spec
  # https://tools.ietf.org/html/rfc2822 for more info
  def normalized
    @email = ANGLE_ADDR =~ @email ? Regexp.last_match(1) : @email
    @email.strip
  end

  def valid_email_or_nil
    @email = AT_SYMBOL =~ @email ? Regexp.last_match.to_s : nil
  end
end
