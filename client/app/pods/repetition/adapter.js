import ApplicationAdapter from 'tahi/adapters/application';

export default ApplicationAdapter.extend({
  urlForDeleteRecord(id, modelName, snapshot) {
    let options = snapshot.adapterOptions || {};

    if(options.destroyingAll){
      // All repetitions are being destroyed, so do not ask
      // for any updated positions.  This prevents an issue
      // where many repetitions are being destroyed quickly
      // and returning the position for a deleted record will
      // cause an ember 'inflight' error.
      return `/api/repetitions/${id}?destroying_all=true`;
    } else {
      return `/api/repetitions/${id}`;
    }
  }
});
