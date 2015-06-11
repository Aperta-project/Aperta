`import Ember from 'ember'`
`import { test, moduleForComponent } from 'ember-qunit'`

moduleForComponent 'question', 'Component: question-component',
  setup: ->
    @fakeStore =
      createRecord: (type, {question, task, ident}) ->
        equal type, 'question', 'creates a new question'
        Ember.Object.create(ident: ident, task: task, question: question)
    @q1 = Ember.Object.create(ident: "foo")
    @q2 = Ember.Object.create(ident: "bar")


test '#model: gets tasks questions by ident', ->
  task = Ember.Object.create(questions: [@q1, @q2])

  component = @subject(task: task, ident: "foo")
  equal component.get('model'), @q1, 'Finds its model by ident'

test '#createNewQuestion: creates a new question and adds it to the task if it cant find one', ->
  task = Ember.Object.create(questions: [@q1], store: @fakeStore)

  component = @subject(task: task, ident: "bar")
  model = component.get('model')

  equal model.get('ident'), 'bar', "The model has the task's ident"
  ok task.get('questions').contains(model), 'the model is added to the task'

test '#model.additionalData: set additional data onto model', ->
  task = Ember.Object.create(questions: [@q2], store: @fakeStore)

  component = @subject(task: task, ident: "foo", additionalDataKey: "key2", additionalDataValue: "value2")
  question = component.get("model.task.questions").filterBy('ident', 'foo')[0]
  additionalDataObject = question.get("additionalData")[0]

  equal additionalDataObject["key2"], "value2"
