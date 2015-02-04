`import DS from 'ember-data'`

a = DS.attr

Journal = DS.Model.extend

  reviewers: DS.hasMany('user')

  logoUrl: a('string')
  name: a('string')
  paperTypes: a()
  manuscriptCss: a('string')

`export default Journal`
