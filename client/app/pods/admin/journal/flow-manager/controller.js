import Ember from 'ember';
import resizeColumnHeaders from 'tahi/lib/resize-column-headers';

export default Ember.Controller.extend({
  flowSort: ['position:asc'],
  sortedFlows: Ember.computed.sort('model.flows', 'flowSort'),

  newFlowPosition() {
    return this.get('sortedFlows.lastObject.position') + 1;
  },

  actions: {
    saveFlow(flow) {
      flow.save().then(function() {
        Ember.run.schedule('afterRender', resizeColumnHeaders);
      });
    },

    removeFlow(flow) {
      flow.destroyRecord();
    },

    addFlow() {
      this.store.createRecord('flow', {
        title: 'Up for grabs',
        oldRole: this.get('model'),
        position: this.newFlowPosition(),
        query: {},
        taskRoles: []
      }).save();
    },

    viewCard() { }
  }
});
