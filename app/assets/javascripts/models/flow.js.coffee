ETahi.Flow = DS.Model.extend ETahi.CommonFlowAttrs,
  role: DS.belongsTo('role')
  relationshipsToSerialize: ['role']
  position: DS.attr('number')
  query: DS.attr()
