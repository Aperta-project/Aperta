a = DS.attr
ETahi.Figure = DS.Model.extend
  filename: a('string')
  alt: a('string')
  src: a('string')
  paper: DS.belongsTo('paper')
