a = DS.attr
ETahi.Journal = DS.Model.extend
  reviewers: DS.hasMany('user')
  logoUrl: a('string')
  name: a('string')
  paperTypes: a()
  taskTypes: a()
  epubCoverUrl: a('string')
  epubCoverFileName: a('string')
  epubCoverUploadedAt: a('string')
