`import Ember from 'ember'`

Table = Ember.Object.extend

  paper: null
  id: ''
  title: ''
  tableHtml: ''
  caption: ''

  toHtml: ->
    """
    <figure itemscope data-id="#{@get('id')}" data-type="table">
      <h1 itemprop="title">#{@get('title')}</h1>
      #{@get('tableHtml')}
      <figcaption>#{@get('caption')}</figcaption>
    </figure>
    """

  save: ->
    console.log('Saving table')
    return new Promise((resolve, reject) ->
      resolve()
    )


__id__ = 0

Table.nextId = (->
  __id__++
)

`export default Table`
