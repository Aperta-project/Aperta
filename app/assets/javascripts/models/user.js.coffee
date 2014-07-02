a = DS.attr
ETahi.User = DS.Model.extend
  admin: a('boolean')
  affiliations: DS.hasMany('affiliation')
  email: a('string')
  fullName: a('string')
  avatarUrl: a('string')
  username: a('string')
  name: Ember.computed.alias 'fullName'

  affiliationSort: ['isCurrent:desc', 'endDate:desc', 'startDate:asc']
  affiliationsByDate: Ember.computed.sort('affiliations', 'affiliationSort')

ETahi.Assignee = ETahi.User.extend()
ETahi.Reviewer = ETahi.User.extend()
