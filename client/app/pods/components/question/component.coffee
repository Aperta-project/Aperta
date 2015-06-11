`import Ember from 'ember'`

QuestionComponent = Ember.Component.extend
  tagName: 'div'
  helpText: null
  displayContent: false

  model: (->
    ident = @get('ident')
    throw new Error("You must specify an ident, set to name attr") unless ident

    question =
      if @get("versioned")
        @get('task.paper.latestDecision.questions').findProperty('ident', ident)
      else
        @get('task.questions').findProperty('ident', ident)

    unless question
      question = @createNewQuestion()

    question
  ).property('task', 'ident')

  createNewQuestion: ->
    task = @get('task')
    question = task.get('store').createRecord 'question',
      question: @get('question')
      ident: @get('ident')
      task: task
      decision: task.get('paper.latestDecision')
      additionalData: [{}]

    data = {}
    key = @get("additionalDataKey")
    value = @get("additionalDataValue")
    if key && value
      data[key] = value
      question.set("additionalData", [data])

    task.get('questions').pushObject(question)
    question

  additionalData: Ember.computed.alias('model.additionalData')

  change: ->
    Ember.run.debounce(this, this._saveModel, @get('model'), 200)
    false

  _saveModel: (model) ->
    model.save()

`export default QuestionComponent`
