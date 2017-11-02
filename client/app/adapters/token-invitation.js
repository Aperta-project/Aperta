import ApplicationAdapter from 'tahi/adapters/application';

export default ApplicationAdapter.extend({
  queryRecord(store, type, { token }){
    var path = `/${this.get('namespace')}/${this.get('pathForType')(type.modelName)}/${token}`;
    return this.ajax(path, 'GET');
  },
  headers: function(){
    var headers = this._super(...arguments);
    // pusher doesn't setup right w/o current user
    delete headers['Pusher-Socket-ID'];
    return headers;
  }
});
