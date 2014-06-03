a = DS.attr
ETahi.Figure = DS.Model.extend
  figureTask: DS.belongsTo('figureTask')
  alt: a('string')
  filename: a('string')
  src: a('string')
  title: a('string')
  caption: a('string')
  previewSrc: a('string')
