`import TaskController from 'tahi/pods/paper/task/controller'`

CoverLetterController = TaskController.extend
  letterBody: Ember.computed ->
    @model.get('body')[0]

  editingLetter: Ember.computed ->
    false

  actions:
    saveCoverLetter: ->
      @model.set 'body', [@get('letterBody')]
      @model.save().then =>
        @set 'editingLetter', true

    editCoverLetter: ->
      @set 'editingLetter', false

`export default CoverLetterController`
