// This component is a thin layer around the card-content components;
// it takes a card-content json blob and displays the right component
// to view that blob in a task. To change which component goes with
// which content type, edit client/lib/card-content-types.js

import Ember from 'ember';
import CardContentTypes from 'tahi/lib/card-content-types';

export default Ember.Component.extend({
  contentType: Ember.computed('content.contentType', function() {
    let type = this.get('content.contentType');
    return CardContentTypes.forType(type);
  }),

  templateName: Ember.computed.reads('contentType.viewComponent')
});
