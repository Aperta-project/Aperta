import ApplicationSerializer from 'tahi/serializers/application';

export default ApplicationSerializer.extend({
  normalizeHash: {
    tasks(hash) {
      return hash = this.normalizeType(hash);
    }
  }
});
