module 'Integration: Reporting Guidelines Card',
  teardown: -> ETahi.reset()
  setup: ->
    setupApp integration: true
    TahiTest.paperId = 4245
    TahiTest.figureTaskId = 949
    TahiTest.authorId = 19347

test 'Supporting Guideline is a meta data card', ->
  ok true
  visit ''
