import ApplicationSerializer from 'tahi/pods/application/serializer';

export default ApplicationSerializer.extend({
  normalizeHash: {
    tasks(hash) {
      return hash = this.normalizeType(hash);
    }
  }
});
