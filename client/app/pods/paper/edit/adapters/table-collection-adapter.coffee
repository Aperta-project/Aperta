`import Ember from 'ember'`
`import CollectionAdapter from './collection-adapter'`

# Observes items of a table collection and updates the corresponding VE model or the Ember model vice versa.
TableCollectionAdapter = Ember.Object.extend CollectionAdapter,

  modelType: 'table'
  collection: Ember.computed.alias('paper.tables')
  editEvent: 'table:edited'
  editableFields: ['title', 'body', 'caption']

  getNodeIndex: ->
    @get('doc').getIndex('table-nodes')

  saveNodeToModel: (node, model) ->
    newTitle = node.getPropertyNode('title').toHtml()
    model.set('title', newTitle)
    newBody = node.getPropertyNode('table').toHtml()
    model.set('body', newBody)
    newCaption = node.getPropertyNode('caption').toHtml()
    model.set('caption', newCaption)

  loadNodeFromModel: (node, model) ->
    surface = @get('editor').getSurface()
    # title
    oldTitle = node.getPropertyNode('title').toHtml()
    newTitle = model.get('title')
    if oldTitle != newTitle
      node.getPropertyNode('title').fromHtml(newTitle)
    # body
    oldBody = node.getPropertyNode('table').toHtml()
    newBody = model.get('body')
    if oldBody != newBody
      node.getPropertyNode('table').fromHtml(newBody, surface)
    #caption
    oldCaption = node.getPropertyNode('caption').toHtml()
    newCaption = model.get('caption')
    if oldCaption != newCaption
      node.getPropertyNode('caption').fromHtml(newCaption)

`export default TableCollectionAdapter`
