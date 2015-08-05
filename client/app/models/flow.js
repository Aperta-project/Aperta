import DS from 'ember-data';
import CommonFlowAttrs from 'tahi/mixins/models/common-flow-attrs';

export default DS.Model.extend(CommonFlowAttrs, {
  role: DS.belongsTo('role', { async: false }),
  position: DS.attr('number'),
  query: DS.attr()
});
