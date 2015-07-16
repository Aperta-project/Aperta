import Ember from 'ember';
import DragNDrop from 'tahi/services/drag-n-drop';

export default Ember.Component.extend(DragNDrop.DroppableMixin, {
  classNames: ['column'],

  nextPosition: function() {
    return this.get('content.position') + 1;
  }.property('content.position'),

  removeDragStyles() {
    this.$().removeClass('current-drop-target');
  },

  dragOver() {
    this.$().addClass('current-drop-target');
  },

  dragLeave() {
    this.removeDragStyles();
  },

  dragEnd() {
    this.removeDragStyles();
  },

  drop(e) {
    this.removeDragStyles();
    this.get('controller').send(
      'changeTaskPhase',
      DragNDrop.dragItem,
      this.get('content')
    );
    DragNDrop.dragItem = null;
    return DragNDrop.cancel(e);
  }
});
