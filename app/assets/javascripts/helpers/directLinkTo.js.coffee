Ember.Handlebars.registerBoundHelper 'directLinkTo', (url, label, classString, mime) ->
  classAttr = "class=\"" + classString + "\""
  url += "." + mime if mime
  link = "<a href=\"" + url + "\"" + classAttr + ">" + label + "</a>"
  new Em.Handlebars.SafeString(link)
