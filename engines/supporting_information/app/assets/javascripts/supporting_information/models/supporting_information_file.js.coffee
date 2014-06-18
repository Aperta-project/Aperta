a = DS.attr
ETahi.SupportingInformationFile = DS.Model.extend
  paper: DS.belongsTo('paper')
  alt: a('string')
  filename: a('string')
  src: a('string')
  status: a('string')
  title: a('string')
  caption: a('string')

  resetPaper: ( ->
    paper = @get('paper')
    @set('paper', null)
    @set('paper', paper)
  ).on('didLoad')
