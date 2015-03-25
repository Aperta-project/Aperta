`import DS from 'ember-data'`

a = DS.attr

Funder = DS.Model.extend
  task: DS.belongsTo('financialDisclosureTask')
  authors: DS.hasMany('author')

  funderHadInfluence: a('boolean')
  funderInfluenceDescription: a('string')
  grantNumber: a('string')
  name: a('string')
  relationshipsToSerialize: ['authors']
  website: a('string')

`export default Funder`
