a = DS.attr
ETahi.AdminJournal = DS.Model.extend
  # journal: DS.belongsTo('journal')
  logoUrl: a('string')
  name: a('string')
  paperTypes: a()
  taskTypes: a()
  manuscriptManagerTemplates: a('manuscriptManagerTemplate')
  roles: DS.hasMany('role')
  epubCoverUrl: a('string')
  epubCoverFileName: a('string')
  epubCoverUploadedAt: a('string')

