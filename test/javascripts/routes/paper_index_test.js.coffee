moduleFor 'route:paperIndex', 'Unit: route/PaperIndex',
  needs: ['model:paper', 'route:paper'],
  setup: ->
    setupApp()
    sinon.stub(@subject(), 'replaceWith')

test 'transition to edit route if paper has been not submitted', ->
  unsubmittedPaper = Ember.Object.create submitted: false
  @subject().afterModel unsubmittedPaper

  ok @subject().replaceWith.calledWithExactly('paper.edit', unsubmittedPaper)

test 'does not transition to edit route if paper has been submitted', ->
  submittedPaper = Ember.Object.create submitted: true
  @subject().afterModel submittedPaper

  ok !@subject().replaceWith.called
