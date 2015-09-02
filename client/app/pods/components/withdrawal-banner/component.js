import Ember from 'ember';
import RESTless from 'tahi/services/rest-less';

export default Ember.Component.extend({
  withdrawn: Ember.computed.equal('paper.publishingState', 'withdrawn'),
  actions: {
    reactivate: function() {
      RESTless.putUpdate(this.get('paper'), '/reactivate')
      .then(()=> {
      });
    }
  }
});
