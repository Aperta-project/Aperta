`import Ember from 'ember'`
`import DS from 'ember-data'`

a = DS.attr

Affiliation = DS.Model.extend

  user: DS.belongsTo('user')

  name: a('string')
  endDate: a('string')
  startDate: a('string')
  email: a('string')

  isCurrent: (->
    Ember.isBlank @get('endDate')
  ).property('endDate')

`export default Affiliation`
