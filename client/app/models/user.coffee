`import DS from 'ember-data'`

a = DS.attr

User = DS.Model.extend
  affiliations: DS.hasMany('affiliation')
  invitations: DS.hasMany('invitation', inverse: 'invitee')

  siteAdmin: a('boolean')
  email: a('string')
  fullName: a('string')
  firstName: a('string')
  avatarUrl: a('string')
  username: a('string')
  name: Ember.computed.alias 'fullName'

  affiliationSort: ['isCurrent:desc', 'endDate:desc', 'startDate:asc']
  affiliationsByDate: Ember.computed.sort('affiliations', 'affiliationSort')

  invitedInvitations: (->
    @get('invitations').filterBy('state', 'invited')
  ).property('invitations.@each.state')

`export default User`
