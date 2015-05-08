export default {
  name: 'reopenDSModel',
  after: 'eventStream',

  initialize: function(container, application) {
    return DS.Model.reopen({
      path() {
        let adapter = this.get('store').adapterFor(this);
        let resourceType = this.constructor.typeKey;
        return adapter.buildURL(resourceType, this.get('id'));
      },
      adapterWillCommit() {
        container.lookup('eventstream:main').pause();
        return this.send('willCommit');
      }
    });
  }
};
