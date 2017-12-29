import Ember from 'ember';
import DragNDrop from 'tahi/pods/drag-n-drop/service';

export default Ember.Component.extend(DragNDrop.DroppableMixin, {
  classNameBindings: [':author-drop-target', 'isEditable::hidden'],

  isEditable: false,

  position: Ember.computed('index', function() {
    return this.get('index') + 1;
  }),

  notAdjacent(thisPosition, dragItemPosition) {
    return thisPosition <= (dragItemPosition - 1) ||
           thisPosition > (dragItemPosition + 1);
  },

  removeDragStyles() {
    this.$().removeClass('current-drop-target');
  },

  dragEnter(e) {
    if(this.notAdjacent(this.get('position'), DragNDrop.dragItem.get('position'))) {
      this.$().addClass('current-drop-target');
      DragNDrop.cancel(e);
    }
  },

  dragLeave() {
    this.removeDragStyles();
  },

  dragEnd() {
    this.removeDragStyles();
  },

  drop(e) {
    this.removeDragStyles();
    this.attrs.changePosition(DragNDrop.dragItem, this.get('position'));
    DragNDrop.set('dragItem', null);
    return DragNDrop.cancel(e);
  }
});
