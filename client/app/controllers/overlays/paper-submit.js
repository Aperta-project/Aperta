import Ember from 'ember';

export default Ember.Controller.extend({
  restless: Ember.inject.service('restless'),
  overlayClass: 'overlay--fullscreen overlay--green paper-submit-overlay',
  paperSubmitted: false,
  previousPublishingState: null,
  isFirstFullSubmission: Ember.computed.equal('previousPublishingState', 'invited_for_full_submission'),

  recordPreviousPublishingState: function(){
    this.set('previousPublishingState', this.get('model.publishingState'));
  },

  actions: {
    submit() {
      this.recordPreviousPublishingState();
      this.get('restless').putUpdate(this.get('model'), '/submit').then(()=> {
        this.set('paperSubmitted', true);
      }, (arg)=> {
        let status = arg.status;
        let model  = arg.model;
        let message;
        switch (status) {
          case 422:
            message = model.get('errors.messages') + " You should probably reload.";
            break;
          case 403:
            message = "You weren't authorized to do that";
            break;
          default:
            message = 'There was a problem saving. Please reload.';
        }

        this.flash.displayMessage('error', message);
      });
    },

    closeSuccessOverlay() {
      this.send('closeOverlay');
      this.set('paperSubmitted', false);
    }
  }
});
