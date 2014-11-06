a = DS.attr
ETahi.Attachment = DS.Model.extend
  attachable: DS.belongsTo('attachable', polymorphic: true)

  previewSrc: a('string')
  src: a('string')
  status: a('string')
  title: a('string')
