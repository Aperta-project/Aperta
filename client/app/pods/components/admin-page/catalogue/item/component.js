import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['admin-catalogue-item'],
  click: function() {
    const action = this.get('action');
    if (action) action();
  }
});
