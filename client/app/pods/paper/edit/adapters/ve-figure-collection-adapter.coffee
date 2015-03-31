`import Ember from 'ember'`
`import FigureAdapter from './ve-figure-adapter'`

FiguresCollectionAdapter = Ember.Object.extend

  controller: null
  paper: null
  doc: null

  # provide figures as hash instead of array
  figures: ( ->
    map = {}
    figures = @get('paper.figures')
    _.each(figures.toArray(), (figure) ->
      map[figure.get('id')] = figure
    )
    map
  ).property('paper.figures.[]')

  figureAdapters: []

  each: (fun, context) ->
    _.each(@get('figures'), fun, context)

  getById: (id) ->
    @get('figures')[id]

  connect: ->
    doc = @get('doc')
    # whenever a figure node is inserted into the manuscript
    # we will create data bindings and update all labels
    doc.getIndex('figure-nodes').connect @,
      add: @didInsertFigure,
      remove: @didRemoveFigure
    @

  disconnect: ->
    doc = @get('doc')
    # whenever a figure node is inserted into the manuscript
    # we will create data bindings and update all labels
    doc.getIndex('figure-nodes').disconnect @
    return @

  loadFromModel: ->
    for adapter in @figureAdapters
      adapter.loadFromModel()
    false

  dispose: ->
    @disconnect()
    @figureAdapters = []
    for adapter in @figureAdapters
      adapter.disconnect()

  didInsertFigure: (figureNode) ->
    id = figureNode.getId()
    figureModel = @get('figures')[id]
    if figureModel
      figureAdapter = FigureAdapter.create(
        controller: @get('controller')
        figure: figureModel
        node: figureNode
      )
      @figureAdapters.push(figureAdapter)
      figureAdapter.connect()
    else
      console.warn('No figure model found for id', id)

  didRemoveFigure: (figureNode) ->
    found = null
    pos = -1
    for adapter, i in @figureAdapters
      if adapter.get('node') == figureNode
        found = adapter
        pos = i
        break
    if found
      adapter = found
      adapter.disconnect()
      @figureAdapters.splice(pos, 1)

`export default FiguresCollectionAdapter`
