a = DS.attr
ETahi.Task = DS.Model.extend
  title: a('string')
  type: a('string')
  completed: a('boolean')
  role: a('string')
  body: a('string')
  messageSubject: a('string')
  comments: DS.hasMany('comment')
  isMessage: Ember.computed.equal('type', 'MessageTask')
  phase: DS.belongsTo('phase')
  assignees: DS.hasMany('user')
  assignee: DS.belongsTo('user')

ETahi.PaperReviewerTask = ETahi.Task.extend
  reviewers: DS.hasMany('user')
  reviewer: DS.belongsTo('user')

ETahi.PaperEditorTask = ETahi.Task.extend
  editors: DS.hasMany('user')
  editor: DS.belongsTo('user')

ETahi.PaperAdminTask = ETahi.Task.extend
  admins: DS.hasMany('user')
  admin: DS.belongsTo('user')

