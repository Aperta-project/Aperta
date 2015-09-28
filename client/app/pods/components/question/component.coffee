`import Ember from 'ember'`

QuestionComponent = Ember.Component.extend
  tagName: 'div'
  helpText: null
  disabled: false,
  readonly: false,

  model: (->
    ident = @get('ident')
    Ember.assert('You must specify an ident, set to name attr', ident)

    task = @get('task')
    Ember.assert('You must specify a task', task)

    decision = @get('decision')

    question =
      if decision
        task.questionForIdentAndDecision ident, decision
      else
        task.get('questions').findProperty('ident', ident)

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
