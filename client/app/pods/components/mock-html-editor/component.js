import Ember from 'ember';

export default Ember.Component.extend({

  paper: null,

  getBodyHtml() {
    return this.get('paper.body');
  },

  update() {},

  connect() {},

  disconnect() {},

  disable() {},

  enable() {},

  writeToModel() {},

});
