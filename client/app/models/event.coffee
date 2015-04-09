`import DS from 'ember-data'`

Event = DS.Model.extend

  eventName: DS.attr('string')
  createdAt: DS.attr('date')

`export default Event`
