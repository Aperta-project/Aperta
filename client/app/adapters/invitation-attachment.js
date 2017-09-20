import ApplicationAdapter from 'tahi/adapters/application';
import DS from 'ember-data';
import Ember from 'ember';

function attachmentURL(id, modelName, snapshot) {
  return `/api/invitations/${snapshot.belongsTo('invitation').id}/attachments/${id}`;
}

export default ApplicationAdapter.extend(DS.BuildURLMixin, {
  urlForFindRecord: attachmentURL,

  urlForDeleteRecord: attachmentURL,

  urlForUpdateRecord: attachmentURL,

  findRecord(store, type, id, snapshot) {
    // this is for the case where a pusher message is received by window without the right data
    return snapshot.belongsTo('invitation') ? this._super(...arguments) : Ember.RSVP.reject();
  }
});
