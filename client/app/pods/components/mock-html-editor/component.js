import Ember from 'ember';

export default Ember.Component.extend({

  paper: null,

  getBodyHtml: function() {
    return this.get('paper.body');
  },

  update: function() {
    // TODO: maybe we want to detect if this got called
  },

  connect: function() {
    // TODO: maybe we want to detect if this got called
  },

  disconnect: function() {
    // TODO: maybe we want to detect if this got called
  },

});
