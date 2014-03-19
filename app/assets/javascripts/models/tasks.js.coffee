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
  assignees: DS.hasMany('assignee')
  assignee: DS.belongsTo('assignee')

ETahi.PaperReviewerTask = ETahi.Task.extend
  reviewers: DS.hasMany('user')
  reviewer: DS.belongsTo('user')

ETahi.PaperEditorTask = ETahi.Task.extend
  editors: DS.hasMany('user')
  editor: DS.belongsTo('user')

ETahi.PaperAdminTask = ETahi.Task.extend
  admins: DS.hasMany('user')
  admin: DS.belongsTo('user')

ETahi.AuthorsTask = ETahi.Task.extend
  authors: DS.hasMany('user')

ETahi.DeclarationTask = ETahi.Task.extend
  declarations: a('string')

ETahi.FigureTask = ETahi.Task.extend
  figures: a('string')

ETahi.TechCheckTask = ETahi.Task.extend()
ETahi.RegisterDecisionTask = ETahi.Task.extend()
ETahi.ReviewerReportTask = ETahi.Task.extend()
ETahi.MessageTask = ETahi.Task.extend()
ETahi.UploadManuscriptTask = ETahi.Task.extend()

