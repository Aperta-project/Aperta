import Ember from 'ember';
import DragNDrop from 'tahi/services/drag-n-drop';

export default Ember.Component.extend(DragNDrop.DroppableMixin, {
  classNameBindings: [':author-drop-target'],

  notAdjacent(thisPosition, dragItemPosition) {
    return thisPosition <= (dragItemPosition - 1) ||
           thisPosition > (dragItemPosition + 1);
  },

  removeDragStyles() {
    this.$().removeClass('current-drop-target');
  },

  dragEnter(e) {
    if(this.validDropZone()) {
      this.$().addClass('current-drop-target');
    }

    DragNDrop.cancel(e);
  },

  dragLeave() {
    this.removeDragStyles();
  },

  dragEnd() {
    this.removeDragStyles();
  },

  drop(e) {
    this.removeDragStyles();
    if(this.validDropZone()) {
      // if the new position is higher than current, decrement that new position
      // by 1 first, but not if it's the last item.
      let position = this.get('position');
      let newPosition = position;
      if (position > DragNDrop.dragItem.get('position') && !this.get('isLast')) {
        newPosition = position -1;
      }

      this.get('changePosition')(newPosition, DragNDrop.dragItem);
      DragNDrop.dragItem = null;
    }
    return DragNDrop.cancel(e);
  },

  validDropZone() {
    return this.notAdjacent(this.get('index'), DragNDrop.dragItem.get('position')) &&
    DragNDrop.dragItem.get('validNewPositionsForInvite')
                    .includes(this.get('position'));
  }
});
