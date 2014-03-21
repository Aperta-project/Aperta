a = DS.attr
ETahi.User = DS.Model.extend
  imageUrl: a('string')
  fullName: a('string')
  name: Ember.computed.alias 'fullName'

ETahi.Assignee = ETahi.User.extend()
ETahi.Reviewer = ETahi.User.extend()
ETahi.AvailableReviewer = ETahi.User.extend()
