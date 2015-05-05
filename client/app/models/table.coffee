`import DS from 'ember-data'`

a = DS.attr

Table = DS.Model.extend
  paper: DS.belongsTo('paper')

  title: a('string')
  body: a('string')
  caption: a('string')

  createdAt: a('date')
  updatedAt: a('date')

  toHtml: ->
    """
    <figure itemscope data-id="#{@get('id')}" data-type="table">
      <h1 itemprop="title">#{@get('title')}</h1>
      #{@get('body')}
      <figcaption>#{@get('caption')}</figcaption>
    </figure>
    """

  saveDebounced: ->
    Ember.run.debounce(@, @save, 2000);

`export default Table`
