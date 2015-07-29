import Ember from 'ember';
import OverlayView from 'tahi/views/overlay';

export default OverlayView.extend({
  templateName: 'overlays/revise',
  layoutName:   'layouts/overlay',
  cardName: 'revise',

  _editIfResponseIsEmpty: Ember.on('didInsertElement', function() {
    this.set(
      'controller.editingAuthorResponse',
      Ember.isEmpty(this.get('controller.latestDecision.authorResponse'))
    );
  })
});
