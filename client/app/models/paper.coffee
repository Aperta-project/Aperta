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
  supportingInformationFiles: DS.hasMany('supporting-information-file')
  tasks: DS.hasMany('task', {async: true, polymorphic: true})

  body: a('string')
  doi: a('string')
  shortTitle: a('string')
  submitted: a('boolean')
  status: a('string')
  title: a('string')
  paperType: a('string')
  eventName: a('string')
  strikingImageId: a('string')
  editable: a('boolean')

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

  unloadRecord: ->
    litePaper = @store.getById('lite-paper', @get('id'))
    @store.unloadRecord(litePaper) if litePaper
    @_super()

`export default Paper`
