`import TaskController from 'tahi/pods/paper/task/controller'`

CoverLetterController = TaskController.extend

  formatCoverLetter: Ember.computed 'letterBody', ->
    result = ""
    @get('model.body')[0].split("\n").forEach (item) ->
      result += "<p>" + item + "</p>"
    new Ember.Handlebars.SafeString(result)

  letterBody: Ember.computed ->
    @model.get('body')[0]

  editingLetter: Ember.computed ->
    if @model.get('body').length == 0 then true else false

  actions:
    saveCoverLetter: ->
      @model.set 'body', [@get('letterBody')]
      @model.save().then =>
        @set 'editingLetter', false

    editCoverLetter: ->
      @set 'editingLetter', true

`export default CoverLetterController`
