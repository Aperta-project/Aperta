a = DS.attr
ETahi.AwesomeAuthor = DS.Model.extend
  authorGroup: DS.belongsTo('authorGroup')

  awesomeName: a('string')

  firstName: a('string')
  middleInitial: a('string')
  lastName: a('string')
  fullName: (->
    [@get('firstName'), @get('middleInitial'), @get('lastName')].compact().join(' ')
  ).property('firstName', 'middleInitial', 'lastName')

  email: a('string')

  title: a('string')
  department: a('string')
  affiliation: a('string')
  secondaryAffiliation: a('string')

  corresponding: a('boolean')
  deceased: a('boolean')
  position: a('number')
