import Ember from 'ember';
import Utils from 'tahi/services/utils';

export default Ember.Controller.extend({
  flowSort: ['position:asc'],
  sortedFlows: Ember.computed.sort('model.flows', 'flowSort'),

  newFlowPosition() {
    return this.get('sortedFlows.lastObject.position') + 1;
  },

  actions: {
    saveFlow(flow) {
      flow.save().then(function() {
        Ember.run.schedule('afterRender', Utils.resizeColumnHeaders);
      });
    },

    removeFlow(flow) {
      flow.get('role.flows').then(function(flows) {
        flows.removeObject(flow);
      });

      flow.destroyRecord();
    },

    addFlow() {
      let flow = this.store.createRecord('flow', {
        title: 'Up for grabs',
        role: this.get('model'),
        position: this.newFlowPosition(),
        query: {},
        taskRoles: []
      });

      flow.save().then(function(flow) {
        flow.get('role.flows').then(function(flows) {
          flows.addObject(flow);
        });
      });
    }
  }
});
