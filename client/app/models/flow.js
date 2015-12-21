import DS from 'ember-data';
import CommonFlowAttrs from 'tahi/mixins/models/common-flow-attrs';

export default DS.Model.extend(CommonFlowAttrs, {
  oldRole: DS.belongsTo('old-role', { async: false }),
  position: DS.attr('number'),
  query: DS.attr()
});
