a = DS.attr
ETahi.Author = DS.Model.extend
  paper: DS.belongsTo('paper')

  firstName: a('string')
  lastName: a('string')
  fullName: (->
    [@get('firstName'), @get('middleInitial'), @get('lastName')].compact().join(' ')
  ).property('firstName', 'middleInitial', 'lastName')
  position: a('number')
