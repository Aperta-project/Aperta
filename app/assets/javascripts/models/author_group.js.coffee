a = DS.attr
ETahi.AuthorGroup = DS.Model.extend
  paper: DS.belongsTo('paper')
  authors: DS.hasMany('author')

  name: a('string')

  hasAuthors: (->
    !Ember.empty(@get('authors'))
  ).property('authors.[]', 'authors.@each')
