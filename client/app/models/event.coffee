`import DS from 'ember-data'`

Event = DS.Model.extend

  name: DS.attr('string')
  createdAt: DS.attr('date')
  actor: DS.attr()
  target: DS.attr()

`export default Event`
