Ember.Handlebars.registerBoundHelper 'directLinkTo', (url, label, classString, mime) ->
  whitelistedMimes = ['pdf']
  classAttr = "class=\"" + classString + "\""
  url += "." + mime if _.contains(whitelistedMimes, mime)
  link = "<a href=\"" + url + "\"" + classAttr + ">" + label + "</a>"
  new Em.Handlebars.SafeString(link)
