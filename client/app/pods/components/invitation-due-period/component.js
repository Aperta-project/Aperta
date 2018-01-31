import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['invitation-item-due'],
  actions: {
    noop(){},
    onInputChange: function (event) {
      if (this.get('value') < 1) { this.set('value', 1); }
      if (this.get('onchange')) { this.get('onchange')(event); }
    }
  }
});
