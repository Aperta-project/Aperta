import Ember from 'ember';

export default Ember.View.extend({
  willDestroyElement() {
    return $(this.get('element')).empty();
  }
});
