import Ember from 'ember';
import EscapeListenerMixin from 'tahi/mixins/escape-listener';

export default Ember.Component.extend(EscapeListenerMixin, {
  flash: Ember.inject.service(),
  restless: Ember.inject.service(),
  paperSubmitted: false,
  previousPublishingState: null,
  isFirstFullSubmission: Ember.computed.equal(
    'previousPublishingState', 'invited_for_full_submission'
  ),

  recordPreviousPublishingState: function(){
    this.set('previousPublishingState', this.get('model.publishingState'));
  },

  actions: {
    submit() {
      this.recordPreviousPublishingState();
      this.get('restless').putUpdate(this.get('model'), '/submit').then(()=> {
        this.set('paperSubmitted', true);
      }, (arg)=> {
        const status = arg.status;
        const model  = arg.model;
        let message;
        switch (status) {
          case 422:
            const errors = model.get('errors.messages');
            message =  errors + ' You should probably reload.';
            break;
          case 403:
            message = 'You weren\'t authorized to do that';
            break;
          default:
            message = 'There was a problem saving. Please reload.';
        }

        this.get('flash').displayMessage('error', message);
      });
    },

    close() {
      this.attrs.close();
    }
  }
});
