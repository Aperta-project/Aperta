import Ember from 'ember';

export default Ember.Component.extend({
  decision: null, // pass in an ember-data Decision
  isEditable: true, // pass in false to disable the rescind button

  busyWhile: null,

  // States:
  confirmingRescind: false,

  classNames: ['rescind-decision'],
  classNameBindings: ['hidden'],
  notDecision: Ember.computed.not('decision'),
  hidden: Ember.computed.or(
    'notDecision', 'decision.draft', 'decision.rescinded'),

  init() {
    this._super(...arguments);
  },

  actions: {
    cancel() {
      this.set('confirmingRescind', false);
    },

    confirmRescind() {
      this.set('confirmingRescind', true);
    },

    rescind() {
      this.set('confirmingRescind', false);
      const promise = this.get('decision').rescind().then(() => {
        Ember.tryInvoke(this, 'afterRescind');
      });
      if (typeof this.attrs.busyWhile === 'function') {
        this.attrs.busyWhile(promise);
      }
    }
  }
});
