a = DS.attr
ETahi.Task = DS.Model.extend
  assignee: DS.belongsTo('user')
  assignees: DS.hasMany('user')
  phase: DS.belongsTo('phase')

  body: a('string')
  completed: a('boolean')
  paperTitle: a('string')
  role: a('string')
  title: a('string')
  type: a('string')
  qualifiedType: a('string')

  isMessage: Ember.computed.equal('type', 'MessageTask')
  paper: Ember.computed.alias('phase.paper')

  #these are both for the SerializesHasMany mixin on TaskSerializer
  relationshipsToSerialize: []
  serializeEmptyRelationships: []

ETahi.PaperReviewerTask = ETahi.Task.extend
  reviewers: DS.hasMany('user')
  relationshipsToSerialize: ['reviewers']
  serializeEmptyRelationships: ['reviewers']

ETahi.PaperEditorTask = ETahi.Task.extend
  editors: DS.hasMany('user')
  editor: DS.belongsTo('user')

ETahi.PaperAdminTask = ETahi.Task.extend
  admins: DS.hasMany('user')
  admin: DS.belongsTo('user')

ETahi.AuthorsTask = ETahi.Task.extend
  authors: Ember.computed.alias('paper.authorsArray')
  qualifiedType: "StandardTasks::AuthorsTask"

ETahi.DeclarationTask = ETahi.Task.extend
  declarations: Ember.computed.alias('paper.declarations')

ETahi.FigureTask = ETahi.Task.extend
  figures: a()

ETahi.MessageTask = ETahi.Task.extend
  participants: DS.hasMany('user')
  comments: DS.hasMany('comment')

  relationshipsToSerialize: ['participants']

ETahi.RegisterDecisionTask = ETahi.Task.extend
  decisionLetters: a('string')
  acceptedLetterTemplate: (->
    JSON.parse(@get('decisionLetters')).Accepted
  ).property 'decisionLetters'
  rejectedLetterTemplate: (->
    JSON.parse(@get('decisionLetters')).Rejected
  ).property 'decisionLetters'
  reviseLetterTemplate: (->
    JSON.parse(@get('decisionLetters')).Revise
  ).property 'decisionLetters'

ETahi.ReviewerReportTask = ETahi.Task.extend
  paperReview: DS.belongsTo('paperReview')

ETahi.TechCheckTask = ETahi.Task.extend
  qualifiedType: "StandardTasks::TechCheckTask"

ETahi.UploadManuscriptTask = ETahi.Task.extend()
