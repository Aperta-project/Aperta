import ActiveModelAdapter from 'active-model-adapter';

export default ActiveModelAdapter.extend({
  namespace: 'api',
  headers: function() {
    return {
      namespace: 'api',
      'PUSHER_SOCKET_ID': this.get('container').lookup('pusher:main').get('socketId')
    };
  }.property().volatile()
});
