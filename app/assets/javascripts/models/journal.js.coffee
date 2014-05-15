a = DS.attr
ETahi.Journal = DS.Model.extend
  reviewers: DS.hasMany('user')
  logoUrl: a('string')
  name: a('string')
  paperTypes: a()
  taskTypes: a()
  manuscriptManagerTemplates: a('manuscriptManagerTemplate')
  roles: DS.hasMany('role')
