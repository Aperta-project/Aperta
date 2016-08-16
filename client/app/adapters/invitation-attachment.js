import ApplicationAdapter from 'tahi/adapters/application';
import DS from 'ember-data';

export default ApplicationAdapter.extend(DS.BuildURLMixin, {
  urlForFindRecord: function(id, modelName, snapshot) {
    return `/api/invitations/${snapshot.belongsTo('invitation').id}/attachments/${id}`;
  }
});
