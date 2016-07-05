import DS from 'ember-data';
import NestedQuestionOwner from 'tahi/models/nested-question-owner';

export default NestedQuestionOwner.extend({
  snapshots: DS.hasMany('snapshot', {
    inverse: 'source',
    async: true
  })
});
