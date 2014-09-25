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

  relationshipsToSerialize: []

  displayTitle: (->
    @get('title') || @get('shortTitle')
  ).property('title', 'shortTitle')

  allMetadataTasksCompleted: (->
    taskArray = @get('tasks')
    if taskArray.get('isPending')
      false
    else
      taskArray.filterBy('isMetadataTask').everyProperty('completed', true)
  ).property('tasks.content.@each.isMetadataTask','tasks.content.@each.completed', 'tasks.isPending')

  editable: (->
    !(@get('allMetadataTasksCompleted') and @get('submitted'))
  ).property('allMetadataTasksCompleted', 'submitted')

  authors: (->
    @get('authorGroups').reduce(
      (result, group) ->
        group.get('authors').forEach (author) ->
          result.pushObject(author)
        result
      [])
  ).property('authorGroups.@each')
