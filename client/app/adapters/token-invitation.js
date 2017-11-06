import ApplicationAdapter from 'tahi/adapters/application';

export default ApplicationAdapter.extend({
  headers: function(){
    var headers = this._super(...arguments);
    // pusher doesn't setup right w/o current user
    delete headers['Pusher-Socket-ID'];
    return headers;
  }
});
