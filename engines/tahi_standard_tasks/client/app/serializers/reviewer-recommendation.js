import ApplicationSerializer from 'tahi/serializers/application';
import DS from 'ember-data';

export default ApplicationSerializer.extend(DS.EmbeddedRecordsMixin, {
  attrs: {
    nestedQuestions: { serialize: true, deserialize: 'ids' }
  }
})
