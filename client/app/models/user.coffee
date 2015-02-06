`import DS from 'ember-data'`

a = DS.attr

User = DS.Model.extend
  siteAdmin: a('boolean')
  affiliations: DS.hasMany('affiliation')
  email: a('string')
  fullName: a('string')
  firstName: a('string')
  avatarUrl: a('string')
  username: a('string')
  name: Ember.computed.alias 'fullName'

  affiliationSort: ['isCurrent:desc', 'endDate:desc', 'startDate:asc']
  affiliationsByDate: Ember.computed.sort('affiliations', 'affiliationSort')

`export default User`
