`import DS from 'ember-data'`

Invitation = DS.Model.extend
  task: DS.belongsTo('task', polymorphic: true)

  title: DS.attr('string')
  abstract: DS.attr('string')
  state: DS.attr('string') # invited|accepted|rejected
  email: DS.attr('string')
  createdAt: DS.attr('date')

  reject: ->
    @set('state', 'rejected')

  accept: ->
    @set('state', 'accepted')

`export default Invitation`
