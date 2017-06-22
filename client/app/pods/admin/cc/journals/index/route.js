import Ember from 'ember';

export default Ember.Route.extend({
  redirect(params) {
    this.transitionTo('admin.cc.journals.workflows', params);
  }

});
