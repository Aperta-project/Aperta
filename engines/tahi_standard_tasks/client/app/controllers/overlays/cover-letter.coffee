`import TaskController from 'tahi/pods/paper/task/controller'`

CoverLetterController = TaskController.extend
  letterBody: Ember.computed ->
    @model.get('body')[0]

  actions:
    saveCoverLetter: ->
      @model.set 'body', [@get('letterBody')]
      @model.save()

`export default CoverLetterController`
