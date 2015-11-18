import Ember from 'ember';
import EscapeListenerMixin from 'tahi/mixins/escape-listener';

export default Ember.Component.extend(EscapeListenerMixin, {
  isLoading: false,
  flows: [],

  groupedFlows: Ember.computed('flows.[]', function() {
    let result = [];

    this.get('flows').forEach(function(flow) {
      const flowJournalName = flow.journal_name || 'Default Flows';

      if (!result.findBy('title', flowJournalName)) {
        result.pushObject(Ember.Object.create({
          title: flowJournalName,
          logo: flow.journal_logo,
          flows: []
        }));
      }

      return result.findBy('title', flowJournalName)
                   .get('flows').pushObject(flow);
    });

    return result;
  }),

  actions: {
    close() {
      this.attrs.close();
    },

    addFlow(flow) {
      this.attrs.addFlow(flow);
      this.attrs.close();
    }
  }
});
