#= require test_helper

moduleFor 'route:paperIndex', 'Unit: route/PaperIndex',
  needs: ['model:paper', 'route:paper'],
  setup: ->
    sinon.stub(@subject(), 'transitionTo')

test 'transition to edit route if paper has been not submitted', ->
  unsubmittedPaper = Ember.Object.create submitted: false
  @subject().afterModel unsubmittedPaper

  ok @subject().transitionTo.calledWithExactly('paper.edit', unsubmittedPaper)

test 'does not transition to edit route if paper has been submitted', ->
  submittedPaper = Ember.Object.create submitted: true
  @subject().afterModel submittedPaper

  ok !@subject().transitionTo.called
