import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Component.extend(ValidationErrorsMixin, {
  close: null,
  restless: Ember.inject.service(),
  store: Ember.inject.service(),
  reason: null,
  correspondenceId: Ember.computed.reads('model.id'),
  paperId: Ember.computed.reads('model.paper.id'),
  softDeletePath() {
    return `/api/papers/${this.get('paperId')}/correspondence/${this.get('correspondenceId')}/soft_delete`;
  },
  reasonClass: Ember.computed('reasonEmpty', function() {
    return this.get('reasonEmpty') ? 'form-control error' : 'form-control';
  }),


  actions: {
    delete() {
      let reason = this.get('reason');
      if(Ember.isEmpty(reason)) {
        this.set('reasonEmpty', true);
      } else {
        this.get('restless').put(this.softDeletePath(), {reason: reason});
        this.sendAction('close');
      }
    },
    clearReasonError() {
      this.set('reasonEmpty', false);
    }
  }
});
