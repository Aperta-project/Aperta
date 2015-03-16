`import Ember from 'ember'`
`import TaskController from 'tahi/pods/task/controller'`


InitialTechCheckOverlayController = TaskController.extend

  taskDidChange: (->
    @set 'authorChanges', false
    @set 'authorChangesLetter', @get('model.changesForAuthorTask.body.initialTechCheckBody')
  ).observes('model')

  authorChanges: (-> false).property()

  authorChangesLetter: (->
    @get('model.changesForAuthorTask.body.initialTechCheckBody')
  ).property('model.changesForAuthorTask', 'model')

  authorChangesLetterPresent: (->
    @get('model.changesForAuthorTask.body.initialTechCheckBody')
  ).property('model.changesForAuthorTask')

  actions:
    makeAuthorChanges: ->
      @set 'authorChanges', true

    updateAuthorChangesCard: ->
      changesForAuthorTask = @get('model.changesForAuthorTask')
      changesForAuthorTask.set 'body',
        initialTechCheckBody: @get 'authorChangesLetter'
      changesForAuthorTask.save().then =>
        @set 'authorChanges', false
        @flash.displayMessage('success', 'Changes for Author Card has been updated on the manuscript page.')

    createAuthorChangesCard: ->
      @store.createRecord 'changes-for-author-task',
        phase: @get('model.phase')
        role: 'author'
        type: 'ChangesForAuthor::ChangesForAuthorTask'
        paper: @get('model.phase.paper')
        title: "Changes For Author"
        body:
          initialTechCheckBody: @get 'authorChangesLetter'
      .save().then (newTask) =>
        @set 'model.changesForAuthorTask', newTask
        @set 'model.body',
          changesForAuthorTaskId: newTask.id
        @model.save().then =>
          @set 'authorChanges', false
          @flash.displayMessage('success', 'Changes for Author Card has been created on the manuscript page.')

`export default InitialTechCheckOverlayController`
