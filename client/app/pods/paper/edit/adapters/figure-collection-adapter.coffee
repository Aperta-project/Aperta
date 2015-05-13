`import Ember from 'ember';`
`import CollectionAdapter from './collection-adapter';`

# Observes items of a figure collection and updates the corresponding VE model or the Ember model vice versa.
FigureCollectionAdapter = Ember.Object.extend CollectionAdapter,

  modelType: 'figure'
  collection: Ember.computed.alias('paper.figures')
  editEvent: 'figure:edited'
  editableFields: ['title', 'src', 'caption']

  getNodeIndex: ->
    @get('doc').getIndex('figure-nodes')

  saveNodeToModel: (node, model) ->
    # title
    newTitle = node.getPropertyNode('title').toHtml()
    model.set('title', newTitle)
    # caption
    newCaption = node.getPropertyNode('caption').toHtml()
    console.log('.... saving changed figure caption', newCaption)
    model.set('caption', newCaption)

  loadNodeFromModel: (node, model) ->
    surface = @get('editor').getSurface()
    # title
    oldTitle = node.getPropertyNode('title').toHtml()
    newTitle = model.get('title')
    if oldTitle != newTitle
      node.getPropertyNode('title').fromHtml(newTitle, surface)
    #src
    oldSrc = node.getPropertyNode('image').getAttribute('src')
    newSrc = model.get('src')
    if oldSrc != newSrc
      console.log('.... loading changed figure image src', newSrc, 'old', oldSrc)
      node.getPropertyNode('image').setSrc(newSrc, surface)
    #caption
    oldCaption = node.getPropertyNode('caption').toHtml()
    newCaption = model.get('caption')
    if oldCaption != newCaption
      console.log('.... loading changed figure caption', newCaption, 'old', oldCaption)
      node.getPropertyNode('caption').fromHtml(newCaption, surface)

`export default FigureCollectionAdapter;`
