a = DS.attr
ETahi.User = DS.Model.extend
  imageUrl: a('string')
  fullName: a('string')
  username: a('string')
  name: Ember.computed.alias 'fullName'
  admin: a('boolean')

ETahi.Assignee = ETahi.User.extend()
ETahi.Reviewer = ETahi.User.extend()
