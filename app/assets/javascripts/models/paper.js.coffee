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

  authorGroups: DS.hasMany('authorGroup')
  figures: DS.hasMany('figure')
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

  relationshipsToSerialize: []

  displayTitle: (->
    @get('title') || @get('shortTitle')
  ).property('title', 'shortTitle')

  allMetadataTasks: (->
    @get('tasks').filterBy('isMetadataTask')
  ).property('tasks.content.@each.isMetadataTask')

  allMetadataTasksCompleted: ETahi.computed.all('allMetadataTasks', 'completed', true)

  editable: (->
    !(@get('allTasksCompleted') and @get('submitted'))
  ).property('allTasksCompleted', 'submitted')
