`import DS from 'ember-data'`

a = DS.attr

Author = DS.Model.extend
  paper: DS.belongsTo('paper')

  firstName: a('string')
  lastName: a('string')
  position: a('number')

  fullName: (->
    [@get('firstName'), @get('middleInitial'), @get('lastName')].compact().join(' ')
  ).property('firstName', 'middleInitial', 'lastName')

`export default Author`
