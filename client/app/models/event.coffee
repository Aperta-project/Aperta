`import DS from 'ember-data'`

Event = DS.Model.extend

  event: DS.attr('string')
  createdAt: DS.attr('datetime')
  actor: DS.attr()
  target: DS.attr()

`export default Event`
