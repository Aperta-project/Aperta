`import Ember from 'ember'`
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

  formattedWebsite: (->
    website = @get('website')
    return null if Ember.isEmpty(website)
    return website if /https?:\/\//.test(website)
    "http://#{website}"
  ).property('website')

`export default Funder`
