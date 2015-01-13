`import DS from 'ember-data'`
`import CommonFlowAttrs from 'tahi/mixins/models/common-flow-attrs'`

UserFlow = DS.Model.extend CommonFlowAttrs,

  journalName: DS.attr('string')
  journalLogo: DS.attr('string')

`export default UserFlow`
