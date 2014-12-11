`import DS from 'ember-data'`

a = DS.attr

Figure = DS.Model.extend
  paper: DS.belongsTo('paper')

  alt: a('string')
  filename: a('string')
  src: a('string')
  status: a('string')
  title: a('string')
  caption: a('string')
  previewSrc: a('string')
  detailSrc: a('string')
  createdAt: a('date')

  #when a figure is loaded via the event stream the paper's
  #hasMany relationship isn't automatically updated.  This
  #is a somewhat well-known ember data bug. we need to manually
  #update the relationship for now.
  updatePaperFigures: ( ->
    paperFigures = @get('paper.figures')
    paperFigures.addObject(this)
  ).on('didLoad')

  isStrikingImage: false
  strikingImageDidChange: (->
    @set 'isStrikingImage', @get('paper.strikingImageId') == @get('id')
  ).observes('paper.strikingImageId').on('didLoad')

`export default Figure`
