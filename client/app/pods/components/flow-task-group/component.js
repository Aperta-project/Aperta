import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'li',

  actions: {
    viewCard(task) {
      this.sendAction('viewCard', task);
    }
  }
});
