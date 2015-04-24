`import DS from 'ember-data'`
`import CardThumbnailObserver from 'tahi/mixins/models/card-thumbnail-observer'`

a = DS.attr

Task = DS.Model.extend CardThumbnailObserver,
  attachments: DS.hasMany('attachment')
  cardThumbnail: DS.belongsTo('card-thumbnail', inverse: 'task')
  comments: DS.hasMany('comment')
  paper: DS.belongsTo('paper', inverse: 'tasks')
  participations: DS.hasMany('participation')
  phase: DS.belongsTo('phase', inverse: 'tasks')
  questions: DS.hasMany('question', inverse: 'task')
  position: a('number')

  body: a()
  completed: a('boolean')
  paperTitle: a('string')
  role: a('string')
  title: a('string')
  type: a('string')
  qualifiedType: a('string')

  isMetadataTask: a('boolean')

`export default Task`
