a = DS.attr
ETahi.Task = DS.Model.extend ETahi.CardThumbnailObserver,
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

  isMetadataTask: false
  isMessage: Ember.computed.equal('type', 'MessageTask')
  paper: DS.belongsTo('paper', async: true)
  litePaper: DS.belongsTo('litePaper')
  cardThumbnail: DS.belongsTo('cardThumbnail', inverse: 'task')

  questions: DS.hasMany('question')

  relationshipsToSerialize: []

ETahi.PaperEditorTask = ETahi.Task.extend
  editors: DS.hasMany('user')
  editor: DS.belongsTo('user')

ETahi.MessageTask = ETahi.Task.extend
  participants: DS.hasMany('user')
  comments: DS.hasMany('comment')
  unreadCommentsCount: a('number')

  relationshipsToSerialize: ['participants']

ETahi.ReviewerReportTask = ETahi.Task.extend
  paperReview: DS.belongsTo('paperReview')
