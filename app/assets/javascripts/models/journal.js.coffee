a = DS.attr
ETahi.Journal = DS.Model.extend
  name: a('string')
  logo: a('string')
  reviewers: DS.hasMany('user')
