`import DS from 'ember-data'`

a = DS.attr

Attachment = DS.Model.extend

  attachable: DS.belongsTo('attachable', polymorphic: true)

  caption: a('string')
  previewSrc: a('string')
  src: a('string')
  status: a('string')
  title: a('string')
  createdAt: a('date')
  updatedAt: a('date')

`export default Attachment`
