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
    return map;
  ).property('paper.figures.[]')

  figureAdapters: []

  each: (fun, context) ->
    figures = @get('figures')
    _.each(figures, fun, context)

  getById: (id) ->
    figures = @get('figures')[id]

  connect: ->
    doc = @get('doc')
    # whenever a figure node is inserted into the manuscript
    # we will create data bindings and update all labels
    doc.getIndex('figure-nodes').connect @,
      add: @didInsertFigure,
      remove: @didRemoveFigure
    return @

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
    console.log('##### NEW FIGURE')
    id = figureNode.getId()
    figureModel = @get('figures')[id]
    if figureModel
      figureAdapter = FigureAdapter.create(
        controller: @get('controller')
        figure: figureModel
        node: figureNode
      )
      @figureAdapters.push(figureAdapter)
      # Note: we must delay connecting the adapter
      # as it will initially manipulate the node
      # which is not allowed during creation of the node
      # window.setTimeout( ( ->
      figureAdapter.connect()
      # ), 0 )
    else
      console.log('No figure model found for id', id)

  didRemoveFigure: (figureNode) ->
    # console.log('did remove figure', figureNode)
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
