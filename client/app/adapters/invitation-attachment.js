import ApplicationAdapter from 'tahi/adapters/application';
import DS from 'ember-data';

function attachmentURL(id, modelName, snapshot) {
  return `/api/invitations/${snapshot.belongsTo('invitation').id}/attachments/${id}`;
}

export default ApplicationAdapter.extend(DS.BuildURLMixin, {
  urlForFindRecord: attachmentURL,

  urlForDeleteRecord: attachmentURL,

  urlForUpdateRecord: attachmentURL
});
