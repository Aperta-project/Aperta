import Ember from 'ember';

export default Ember.Controller.extend({
  overlayClass: 'flow-manager-column-overlay overlay--fullscreen',

  isLoading: false,
  flows: [],

  groupedFlows: function() {
    let result = [];

    this.get('flows').forEach(function(flow) {
      let flowJournalName = flow.journal_name || 'Default Flows';
      if (!result.findBy('title', flowJournalName)) {
        result.pushObject(Ember.Object.create({
          title: flowJournalName,
          logo: flow.journal_logo,
          flows: []
        }));
      }

      return result.findBy('title', flowJournalName).get('flows').pushObject(flow);
    });

    return result;
  }.property('flows.[]'),

  actions: {
    createFlow(flow) {
      this.store.createRecord('userFlow', {
        title: flow.title,
        flowId: flow.id,
        journalName: flow.journal_name,
        journalLogo: flow.journal_logo
      }).save();

      this.send('closeOverlay');
    }
  }
});
