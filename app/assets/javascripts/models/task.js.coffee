a = DS.attr
ETahi.Task = DS.Model.extend ETahi.CardThumbnailObserver,
  phase: DS.belongsTo('phase', async: true)
  attachments: DS.hasMany('attachment')
  comments: DS.hasMany('comment')
  participations: DS.hasMany('participation')

  body: a()
  completed: a('boolean')
  paperTitle: a('string')
  role: a('string')
  title: a('string')
  type: a('string')
  qualifiedType: a('string')

  isMetadataTask: false
  paper: DS.belongsTo('paper')
  litePaper: DS.belongsTo('litePaper')
  cardThumbnail: DS.belongsTo('cardThumbnail', inverse: 'task')

  questions: DS.hasMany('question', inverse: 'task')
