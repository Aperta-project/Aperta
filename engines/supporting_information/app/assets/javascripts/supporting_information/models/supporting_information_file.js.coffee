a = DS.attr
ETahi.SupportingInformationFile = DS.Model.extend
  paper: DS.belongsTo('paper')
  alt: a('string')
  filename: a('string')
  src: a('string')
  status: a('string')
  title: a('string')
  caption: a('string')

  #when a file is loaded via the event stream the paper's
  #hasMany relationship isn't automatically updated.  This
  #is a somewhat well-known ember data bug. we need to manually
  #update the relationship for now.
  updatePaperFiles: ( ->
    paperFiles = @get('paper.supportingInformationFiles')
    paperFiles.addObject(this)
  ).on('didLoad')
