import ApplicationSerializer from 'tahi/serializers/application';
import SerializesHasMany from 'tahi/mixins/serializers/serializes-has-many';

export default ApplicationSerializer.extend(SerializesHasMany);
