`import DS from 'ember-data'`

Invitation = DS.Model.extend
  task: DS.belongsTo('task', polymorphic: true)

  title: DS.attr('string')
  abstract: DS.attr('string')
  state: DS.attr('string') # invited|accepted|rejected
  email: DS.attr('string')
  createdAt: DS.attr('date')
  updatedAt: DS.attr('date')
  invitationType: DS.attr('string')
  inviteeId: DS.attr('string')
  inviteeFullName: DS.attr('string')
  inviteeAvatarUrl: DS.attr('string')
  invitee: Em.computed 'inviteeFullName', 'inviteeAvatarUrl', ->
    Em.Object.create
      avatarUrl: @get 'inviteeAvatarUrl'
      name: @get 'inviteeFullName'

  accepted: Ember.computed 'state', -> @get('state') is 'accepted'

  reject: ->
    @set('state', 'rejected')

  accept: ->
    @set('state', 'accepted')

`export default Invitation`
