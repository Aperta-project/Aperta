// This component is a thin layer around the card-content components;
// it takes a card-content and displays the right component to view
// that in a task. To change which component goes with which content
// type, edit client/lib/card-content-types.js

import Ember from 'ember';
import CardContentTypes from 'tahi/lib/card-content-types';

export default Ember.Component.extend({
  templateName: Ember.computed('content.contentType', function() {
    let type = this.get('content.contentType');
    return CardContentTypes.forType(type);
  }),

  fakeAnswer: Ember.computed(() => {
    return { value: null };
  }),

  actions: {
    updateFakeAnswer(newVal) {
      this.set('fakeAnswer.value', newVal);
    }
  }
});
