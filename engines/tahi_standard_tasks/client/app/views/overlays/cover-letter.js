import Ember from 'ember';
import OverlayView from 'tahi/views/overlay';

export default OverlayView.extend({
  templateName: 'overlays/cover_letter',
  layoutName: 'layouts/task',

  attributeBindings: ['data-width'],
  'data-width': 0,

  _width: Ember.on('didInsertElement', function() {
    Ember.run.later(this, function() {
      this.set('data-width', this.$().width());
    }, 200);
  })
});
