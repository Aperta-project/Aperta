`import Ember from 'ember'`;

QuestionComponent = Ember.Component.extend
  tagName: 'div'
  helpText: null
  displayContent: false

  model: (->
    ident = @get('ident')
    throw new Error("You must specify an ident, set to name attr") unless ident

    question = @get('task.questions').findProperty('ident', ident)

    unless question
      task = @get('task')
      question = task.get('store').createRecord 'question',
        question: @get('question')
        ident: ident
        task: task
        additionalData: [{}]

      task.get('questions').pushObject(question)

    question

  ).property('task', 'ident')

  additionalData: Em.computed.alias('model.additionalData')

  change: ->
    Ember.run.debounce(this, this._saveModel, @get('model'), 200)
    false

  _saveModel: (model) ->
    model.save()

`export default QuestionComponent`
