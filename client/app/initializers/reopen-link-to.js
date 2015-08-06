import Ember from 'ember';

export default {
  name: 'reopenLinkTo',
  initialize() {
    Ember.LinkComponent.reopen({
      attributeBindings: ['data-toggle', 'data-placement', 'title']
    });
  }
};
