import Ember from 'ember';

export default Ember.Component.extend({

  paper: null,

  getBodyHtml() {
    return this.get('paper.body');
  },

  connect() {},

  disconnect() {},

  disable() {},

  enable() {},

  update() {},

  writeToModel() {},

});
