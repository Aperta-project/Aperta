a = DS.attr
ETahi.User = DS.Model.extend
  admin: a('boolean')
  affiliation: a('string')
  email: a('string')
  fullName: a('string')
  imageUrl: a('string')
  username: a('string')
  name: Ember.computed.alias 'fullName'

ETahi.CurrentUser = ETahi.User.extend()
ETahi.Assignee = ETahi.User.extend()
ETahi.Reviewer = ETahi.User.extend()
