import ApplicationAdapter from 'tahi/adapters/application';

export default ApplicationAdapter.extend({
  queryRecord(store, type, { token }){
    var path = `/${this.get('namespace')}/${this.get('pathForType')(type.modelName)}/${token}`;
    return this.ajax(path, 'GET');
  }
});
