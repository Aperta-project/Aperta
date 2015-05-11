import Ember from 'ember';

export default Ember.View.extend({
  willDestroyElement: function() {
    return $(this.get('element')).empty();
  }
});
