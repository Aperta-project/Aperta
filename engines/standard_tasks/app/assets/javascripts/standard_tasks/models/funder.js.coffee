a = DS.attr
ETahi.Funder = DS.Model.extend
  name: a('string')
  grantNumber: a('string')
  website: a('string')
  funderHadInfluence: a('boolean')
  funderInfluenceDescription: a('string')
  task: DS.belongsTo('financialDisclosureTask')
  authors: DS.hasMany('author')

  relationshipsToSerialize: ['authors']
