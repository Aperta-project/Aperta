import ApplicationSerializer from 'tahi/serializers/application';

export default ApplicationSerializer.extend({
  serialize(snapshot) {
    let json = this._super(...arguments);
    if (!snapshot.record.get('adminContentDirty')) {
      delete json['admin_content'];
    } else
      json['content_changed'] = true;
    return json;
  }
});
