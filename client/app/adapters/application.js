import DS from 'ember-data';

export default DS.ActiveModelAdapter.extend({
  namespace: 'api',
  headers: function() {
    return {
      namespace: 'api',
      'PUSHER_SOCKET_ID': this.get('container').lookup('pusher:main').get('socketId')
    }
  }.property().volatile()
});
