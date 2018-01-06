import ApplicationSerializer from 'tahi/pods/application/serializer';
import DS from 'ember-data';

export default ApplicationSerializer.extend(DS.EmbeddedRecordsMixin, {
  attrs: {
    attachments: {embedded: 'always'}
  }
});
