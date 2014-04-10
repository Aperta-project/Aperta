#= require test_helper

moduleFor 'route:paperIndex', 'Unit: route/PaperIndex',
  needs: ['model:paper', 'route:paper'],
  setup: -> sinon.stub(@subject(), 'modelFor')

test 'the model should be paper', ->
  @subject().model()
  ok @subject().modelFor.calledWith('paper')
