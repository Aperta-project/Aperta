import Ember from 'ember';
import { task } from 'ember-concurrency';

export default Ember.Component.extend({
  classNames: ['card-content', 'card-content-export-paper'],
  owner: null, //owner
  content: null, //card content
  disabled: false,
  store: Ember.inject.service(),
  task: Ember.computed.reads('owner'),
  destination: Ember.computed.reads('content.text'),
  createExportDelivery: task(function * () {
    if (this.get('disabled')) {
      return;
    }
    const exportDelivery = this.get('store').createRecord('export-delivery', {
      task: this.get('task'),
      destination: this.get('destination')
    });

    try {
      yield exportDelivery.save();
      this.get('success')(exportDelivery);
    } catch (e) {
      this.set('errors', exportDelivery.get('errors'));
    }
  }),
  actions: {
    sendToApex() {
      this.get('createExportDelivery').perform();
    }
  }
});
