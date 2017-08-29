import Ember from 'ember';

export default Ember.Controller.extend({
  restless: Ember.inject.service(),

  actions: {
    toggleFlag(flag) {
      flag.toggleProperty('active');
      flag.save().catch((e)=> {
        flag.toggleProperty('active');
        alert(e);
      });
    },
  }
});
