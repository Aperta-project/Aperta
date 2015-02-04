`import DS from 'ember-data'`
`import CommonFlowAttrs from 'tahi/mixins/models/common-flow-attrs'`

Flow = DS.Model.extend CommonFlowAttrs,

  role: DS.belongsTo('role')

  position: DS.attr('number')
  query: DS.attr()

  relationshipsToSerialize: ['role']

`export default Flow`
