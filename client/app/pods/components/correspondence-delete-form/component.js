import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Component.extend(ValidationErrorsMixin, {
  close: null,
  restless: Ember.inject.service(),
  store: Ember.inject.service(),
  reason: null,
  correspondenceId: Ember.computed.reads('model.id'),
  paperId: Ember.computed.reads('model.paper.id'),
  reasonClass: Ember.computed('reasonEmpty', function() {
    return this.get('reasonEmpty') ? 'form-control error' : 'form-control';
  }),


  actions: {
    delete() {
      let reason = this.get('reason');
      if(Ember.isEmpty(reason)) {
        this.set('reasonEmpty', true);
      } else {
        let model = this.get('model');
        model.set('status', 'deleted');
        model.set('additionalContext', {delete_reason: reason});
        model.save().then(() => {
          this.sendAction('close');
        });
      }
    },
    clearReasonError() {
      this.set('reasonEmpty', false);
    }
  }
});
