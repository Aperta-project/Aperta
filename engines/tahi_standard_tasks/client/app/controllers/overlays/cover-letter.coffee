`import TaskController from 'tahi/pods/paper/task/controller'`

CoverLetterController = TaskController.extend
  letterBody: Ember.computed ->
    @model.get('body')

  editingLetter: Ember.computed ->
    if @get('letterBody').length == 0 then true else false

  actions:
    saveCoverLetter: ->
      @model.set 'body', [@get('letterBody')]
      @model.save().then =>
        @set 'editingLetter', false

    editCoverLetter: ->
      @set 'editingLetter', true

`export default CoverLetterController`
