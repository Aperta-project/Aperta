import DS from 'ember-data';
import CommonFlowAttrs from 'tahi/mixins/models/common-flow-attrs';

export default DS.Model.extend(CommonFlowAttrs, {
  journalName: DS.attr('string'),
  journalLogo: DS.attr('string')
});
