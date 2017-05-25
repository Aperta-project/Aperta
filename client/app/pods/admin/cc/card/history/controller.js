import Ember from 'ember';

export default Ember.Controller.extend({
  cardVersions: Ember.computed.reads('model')
});
