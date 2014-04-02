a = DS.attr
ETahi.Journal = DS.Model.extend
  reviewers: DS.hasMany('user')
  logo: a('string')
  name: a('string')
