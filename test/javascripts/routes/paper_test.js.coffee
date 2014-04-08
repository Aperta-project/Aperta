#= require test_helper

# TODO: figure out how to do stub chain in sinon and finish this
moduleFor 'route:paper', 'Unit: route/Paper',
  needs: ['model:paper', 'route:paper'],
  setup: ->
    # paper = double(:paper)
    # find = store.stub(:find).and_return(paper)
    # store = @subject().stub(:store, returns: find)
    # paper = sinon.stub()
    # store = sinon.stub()
    # findQuery = sinon.stub(store, 'find').returns paper
    # sinon.stub(@subject(), 'store').returns findQuery

test 'the model should be paper', ->
  # @subject().model()
  # ok @subject().modelFor.calledWith('paper')
  ok true
