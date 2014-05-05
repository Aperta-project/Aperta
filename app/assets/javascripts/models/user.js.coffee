a = DS.attr
ETahi.User = DS.Model.extend
  admin: a('boolean')
  affiliations: DS.hasMany('affiliation')
  email: a('string')
  fullName: a('string')
  imageUrl: a('string')
  username: a('string')
  name: Ember.computed.alias 'fullName'

ETahi.Assignee = ETahi.User.extend()
ETahi.Reviewer = ETahi.User.extend()
