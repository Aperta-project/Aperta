import Ember from 'ember';
import RunMixin from 'ember-lifeline/mixins/run';

export default Ember.Component.extend(RunMixin, {
  init() {
    this._super();
    if (this.get('message.attachments.length')) this.runTask('reloadPendingAttachments', 1000);
  },

  reloadPendingAttachments() {
    let pending = this.get('message.attachments').filterBy('status', 'processing');
    pending.forEach(attachment => {
      attachment.reload();
    });
    if (pending.get('length')) this.runTask('reloadPendingAttachments', 1000);
  }
});
