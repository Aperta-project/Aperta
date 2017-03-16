// This component is a thin layer around the card-content components;
// it takes a card-content json blob and displays the right component
// to preview that blob. Often that's the same as the 'view' component
// -- but sometimes, for widgets with fancy behavior, it's different.
// To change which component goes with which content type, edit
// client/lib/card-content-types.js

import Ember from 'ember';
import CardContentTypes from 'tahi/lib/card-content-types';

export default Ember.Component.extend({
  contentType: Ember.computed('content.content_type', function() {
    let type = this.get('content.content_type');
    return CardContentTypes.forType(type);
  }),

  templateName: Ember.computed.reads('contentType.previewComponent')
});
