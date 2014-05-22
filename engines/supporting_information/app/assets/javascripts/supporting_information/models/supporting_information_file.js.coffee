a = DS.attr
ETahi.SupportingInformationFile = DS.Model.extend
  paper: DS.belongsTo('paper')
  alt: a('string')
  filename: a('string')
  src: a('string')
  title: a('string')
  caption: a('string')
