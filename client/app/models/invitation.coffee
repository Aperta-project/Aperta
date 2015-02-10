`import DS from 'ember-data'`

Invitation = DS.Model.extend
  title: DS.attr('string')
  abstract: DS.attr('string')
  state: DS.attr('string')

`export default Invitation`
