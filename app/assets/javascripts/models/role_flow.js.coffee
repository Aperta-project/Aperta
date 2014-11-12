ETahi.RoleFlow = DS.Model.extend ETahi.CommonFlowAttrs,
  role: DS.belongsTo('role')
  relationshipsToSerialize: ['role']
