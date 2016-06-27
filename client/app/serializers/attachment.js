import ApplicationSerializer from 'tahi/serializers/application';

export default ApplicationSerializer.extend({
  serializeIntoHash(data, type, record, options) {
    return data['attachment'] = this.serialize(record, options);
  },
});
