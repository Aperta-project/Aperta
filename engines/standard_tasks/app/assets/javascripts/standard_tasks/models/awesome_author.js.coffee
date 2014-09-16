a = DS.attr
ETahi.AwesomeAuthor = DS.Model.extend
  authorGroup: DS.belongsTo('authorGroup')
  awesomeAuthorsTask: DS.belongsTo('awesomeAuthorsTask')

  awesomeName: a('string')

  firstName: a('string')
  lastName: a('string')
  fullName: (->
    [@get('firstName'), @get('lastName')].compact().join(' ')
  ).property('firstName', 'lastName')
