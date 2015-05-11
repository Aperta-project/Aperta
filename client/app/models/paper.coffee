`import DS from 'ember-data'`

a = DS.attr

Paper = DS.Model.extend
  authors: DS.hasMany('author')
  collaborations: DS.hasMany('collaboration')
  editors: DS.hasMany('user') # these are editors that have been assigned to the paper.
  figures: DS.hasMany('figure', inverse: 'paper')
  journal: DS.belongsTo('journal')
  lockedBy: DS.belongsTo('user')
  phases: DS.hasMany('phase')
  reviewers: DS.hasMany('user') # these are reviewers that have been assigned to the paper.
  decisions: DS.hasMany('decision')
  supportingInformationFiles: DS.hasMany('supporting-information-file')
  tasks: DS.hasMany('task', {async: true, polymorphic: true})
  commentLooks: DS.hasMany('comment-look', inverse: 'paper')

  body: a('string')
  doi: a('string')
  shortTitle: a('string')
  submitted: a('boolean')
  status: a('string')
  title: a('string')
  paperType: a('string')
  editorMode: a('string', {defaultValue: 'html'})
  eventName: a('string')
  strikingImageId: a('string')
  editable: a('boolean')
  roles: a()
  relatedAtDate: a('date')

  displayTitle: (->
    @get('title') || @get('shortTitle')
  ).property('title', 'shortTitle')

  allMetadataTasks: (->
    @get('tasks').filterBy('isMetadataTask')
  ).property('tasks.content.@each.isMetadataTask')

  collaborators: (->
    @get('collaborations').mapBy('user')
  ).property('collaborations.@each')

  allMetadataTasksCompleted: (->
    @get('allMetadataTasks').everyProperty('completed', true)
  ).property('allMetadataTasks.@each.completed')

  roleList: (->
    @get('roles')?.sort().join(', ')
  ).property('roles.@each', 'roles.[]')

  latestDecision: (->
    @get('decisions').findBy 'isLatest', true
  ).property('decisions', 'decisions.@each')

`export default Paper`
