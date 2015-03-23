import Ember from 'ember';
import DragNDrop from 'tahi/services/drag-n-drop';

export default Ember.View.extend(DragNDrop.DroppableMixin, {
  tagName: 'div',
  classNameBindings: [':author-drop-target', 'isEditable::hidden'],

  isEditable: Ember.computed.alias('controller.isEditable'),

  position: function() {
    return this.get('index') + 1;
  }.property('index'),

  notAdjacent: function(thisPosition, dragItemPosition) {
    return thisPosition <= (dragItemPosition - 1) || thisPosition > (dragItemPosition + 1);
  },

  removeDragStyles: function() {
    this.$().removeClass('current-drop-target');
  },

  dragEnter: function(e) {
    if(this.notAdjacent(this.get('position'), DragNDrop.dragItem.get('position'))) {
      this.$().addClass('current-drop-target');
      DragNDrop.cancel(e);
    }
  },

  dragLeave: function(e) {
    this.removeDragStyles();
  },

  dragEnd: function(e) {
    this.removeDragStyles();
  },

  drop: function(e) {
    this.removeDragStyles();
    this.get('controller').shiftAuthorPositions(DragNDrop.dragItem, this.get('position'));
    DragNDrop.dragItem = null;
    return DragNDrop.cancel(e);
  }
});
