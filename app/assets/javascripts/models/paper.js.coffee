a = DS.attr
ETahi.Paper = DS.Model.extend
  assignees: DS.hasMany('user')
  editors: DS.hasMany('user')
  reviewers: DS.hasMany('user')
  editor: Ember.computed.alias('editors.firstObject')
  collaborations: DS.hasMany('collaboration')

  collaborators: (->
    @get('collaborations').mapBy('user')
  ).property('collaborations.@each')

  authors: DS.hasMany('author')
  figures: DS.hasMany('figure', inverse: 'paper')
  supportingInformationFiles: DS.hasMany('supportingInformationFile')
  journal: DS.belongsTo('journal')
  phases: DS.hasMany('phase')
  tasks: DS.hasMany('task', {async: true, polymorphic: true})
  lockedBy: DS.belongsTo('user')

  body: a('string')
  shortTitle: a('string')
  submitted: a('boolean')
  status: a('string')
  title: a('string')
  paperType: a('string')
  eventName: a('string')
  strikingImageId: a('string')
  editable: a('boolean')

  relationshipsToSerialize: []

  displayTitle: (->
    @get('title') || @get('shortTitle')
  ).property('title', 'shortTitle')

  allMetadataTasks: (->
    @get('tasks').filterBy('isMetadataTask')
  ).property('tasks.content.@each.isMetadataTask')

  allMetadataTasksCompleted: ETahi.computed.all('allMetadataTasks', 'completed', true)
