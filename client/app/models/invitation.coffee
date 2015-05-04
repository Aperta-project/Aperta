`import DS from 'ember-data'`

Invitation = DS.Model.extend
  task: DS.belongsTo('task', polymorphic: true)
  invitee: DS.belongsTo('user', inverse: 'invitations')

  title: DS.attr('string')
  abstract: DS.attr('string')
  state: DS.attr('string') # invited|accepted|rejected
  email: DS.attr('string')
  createdAt: DS.attr('date')
  updatedAt: DS.attr('date')
  invitationType: DS.attr('string')

  accepted: Ember.computed 'state', -> @get('state') is 'accepted'

  reject: ->
    @set('state', 'rejected')

  accept: ->
    @set('state', 'accepted')

`export default Invitation`
