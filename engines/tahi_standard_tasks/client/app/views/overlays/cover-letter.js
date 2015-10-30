import Ember from 'ember';
import OverlayView from 'tahi/views/overlay';

export default OverlayView.extend({
  templateName: 'overlays/cover_letter',
  layoutName: 'layouts/task',

  attributeBindings: ['data-width'],
  'data-width': 0,

  minWidth: 450,
  startX: 0,
  updateWidth() {
    this.set('data-width', this.$().width());
  },

  _setInitialWidth: Ember.on('didInsertElement', function(){
    Ember.run.later(()=> {
      this.updateWidth();
    }, 50);
  }),

  _startDragListen: Ember.on('didInsertElement', function() {
    const self    = this;
    const overlay = $('#overlay');
    const element = this.$();
    const handle  = this.$('.task-drag-handle');

    const down = 'mousedown.' + self.elementId;
    const move = 'mousemove.' + self.elementId;
    const up   = 'mouseup.'   + self.elementId;

    handle.on(down, function(e) {
      const startWidth = overlay.width();
      self.set('startX', e.pageX);
      $('html').addClass('dragging');

      $(document).on(move, function(event) {
        const change = self.get('startX') - event.pageX;
        const newWidth = startWidth + change;
        overlay.css('width', newWidth);
        Ember.run.debounce(self, self.updateWidth, 50);
      });
    });

    $(document).on(up, function() {
      $('html').removeClass('dragging');
      $(document).off(move);
    });
  }),

  _endDragListen: Ember.on('willDestroyElement', function() {
    this.$('.task-drag-handle').off();
  })
});
