import Ember from 'ember';

export default Ember.Route.extend({
  beforeModel(){
    if (this.currentUser) { this.transitionTo('dashboard'); }
  }

});
