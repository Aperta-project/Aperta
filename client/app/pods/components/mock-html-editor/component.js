import Ember from 'ember';

export default Ember.Component.extend({

  paper: null,

  getBodyHtml() {
    return this.get('paper.body');
  },

  update() {
    // TODO: maybe we want to detect if this got called
  },

  connect() {
    // TODO: maybe we want to detect if this got called
  },

  disconnect() {
    // TODO: maybe we want to detect if this got called
  },

});
