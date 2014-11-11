ETahi.RoleFlow = DS.Model.extend ETahi.CommonFlowAttrs,
  role: DS.belongsTo('role', async: true)
  relationshipsToSerialize: ['role']
