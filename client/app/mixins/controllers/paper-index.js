import Ember from 'ember';

const { computed } = Ember;

export default Ember.Mixin.create({
  errorText: '',

  // removed userEditingMessage and saveStateMessage
  statusMessage: computed.or('processingMessage'),

  processingMessage: computed('model.status', function() {
    return this.get('model.status') === 'processing' ? 'Processing Manuscript' : null;
  })
});
