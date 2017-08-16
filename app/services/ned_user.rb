# Class for looking up users in NED
# as per https://confluence.plos.org/confluence/pages/viewpage.action?pageId=46501211
class NedUser < NedConnection
  def email_has_account?(email, partial = false)
    query_hash = {
      entity: 'email',
      attribute: 'emailaddress',
      value: email,
      partial: partial
    }
    search("individuals?#{query_hash.to_query}")
    true
  rescue ConnectionError => e
    raise e unless e.message == RNF_MESSAGE
    false
  end
end
