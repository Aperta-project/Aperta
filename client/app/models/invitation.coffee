`import DS from 'ember-data'`

Invitation = DS.Model.extend
  title: DS.attr('string')
  abstract: DS.attr('string')
  state: DS.attr('string')

  reject: ->
    @set('state', 'rejected')

  accept: ->
    @set('state', 'accepted')

`export default Invitation`
