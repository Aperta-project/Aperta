`import Ember from 'ember'`
`import { test, moduleForComponent } from 'ember-qunit'`

moduleForComponent 'question', 'Component: question-component',
  beforeEach: ->
    @fakeStore =
      createRecord: (type, {question, task, ident}) ->
        equal type, 'question', 'creates a new question'
        Ember.Object.create(ident: ident, task: task, question: question)
    @q1 = Ember.Object.create(ident: "foo")
    @q2 = Ember.Object.create(ident: "bar")

test '#model: gets tasks questions by ident', (assert) ->
  q3 = Ember.Object.create(ident: 'foo')
  otherTask = Ember.Object.create(questions: [q3])
  task = Ember.Object.create(questions: [@q1, @q2])

  component = @subject(task: task, ident: "foo")
  assert.equal component.get('model'), @q1, 'Finds its model by ident'
  assert.notEqual component.get('model'), q3, 'Does not find a question with the same ident attached to another task'

test '#model: gets tasks questions by ident tied to a particular decision', (assert) ->
  q3 = Ember.Object.create(ident: 'foo')
  q4 = Ember.Object.create(ident: 'foo')
  decision = Ember.Object.create(questions: [q4])

  task = Ember.Object.create
    questions: [@q1, @q2]
    decision: decision
    questionForIdentAndDecision: (ident, decision) ->
      q4
  q4.set('task', task)

  sinon.spy(task, "questionForIdentAndDecision")

  component = @subject(task: task, ident: "foo", decision: decision)

  assert.equal component.get('model'), q4, 'Finds its model by ident'
  assert.notEqual component.get('model'), q3, 'Does not find a question with the same ident attached to another task'
  assert.notEqual component.get('model'), @q2, 'Does not find a old version of a question with the same ident'
  assert.ok task.questionForIdentAndDecision.calledWith('foo', decision), "Expected the question to be looked up with the appropriate ident and decision, but it wasn't"

test '#createNewQuestion: creates a new question and adds it to the task if it cant find one', (assert) ->
  task = Ember.Object.create(questions: [@q1], store: @fakeStore)

  component = @subject(task: task, ident: "bar")
  model = component.get('model')

  assert.equal model.get('ident'), 'bar', "The model has the task's ident"
  assert.ok task.get('questions').contains(model), 'the model is added to the task'

test '#model.additionalData: set additional data onto model', (assert) ->
  task = Ember.Object.create(questions: [@q2], store: @fakeStore)

  component = @subject(task: task, ident: "foo", additionalDataKey: "key2", additionalDataValue: "value2")
  question = component.get("model.task.questions").filterBy('ident', 'foo')[0]
  additionalDataObject = question.get("additionalData")[0]

  assert.equal additionalDataObject["key2"], "value2"
