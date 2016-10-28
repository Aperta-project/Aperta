import Ember from 'ember';
import DragNDrop from 'tahi/services/drag-n-drop';

export default Ember.Component.extend(DragNDrop.DroppableMixin, {
  classNameBindings: [':invitation-drop-target', 'validDropTarget', 'currentDropTarget'],

  DragNDrop: DragNDrop,

  currentDropTarget: false,

  notAdjacent(thisPosition, dragItemPosition) {
    return thisPosition <= (dragItemPosition - 1) ||
           thisPosition > (dragItemPosition + 1);
  },

  removeDragStyles() {
    this.$().removeClass('current-drop-target');
  },

  dragEnter(e) {
    if(this.get('validDropTarget')) {
      this.set('currentDropTarget', true);
    }

    DragNDrop.cancel(e);
  },

  dragLeave() {
    this.set('currentDropTarget', false);
  },

  dragEnd() {
    this.set('currentDropTarget', false);
  },

  validDropTarget: Ember.computed('DragNDrop.dragItem.id', 'index', 'position', function() {
    if (Ember.isEmpty(DragNDrop.get('dragItem'))) { return false; }
    return this.notAdjacent(this.get('index'), DragNDrop.dragItem.get('position')) &&
    DragNDrop.dragItem.get('validNewPositionsForInvitation')
                    .includes(this.get('position'));
  }),

  drop(e) {
    this.set('currentDropTarget', false);
    if(this.get('validDropTarget')) {
      // if the new position is higher than current, decrement that new position
      // by 1 first, but not if it's the last item.
      let position = this.get('position');
      let newPosition = position;
      if (position > DragNDrop.dragItem.get('position') && !this.get('isLast')) {
        newPosition = position -1;
      }

      this.get('changePosition')(newPosition, DragNDrop.dragItem);
      DragNDrop.set('dragItem', null);
    }
    return DragNDrop.cancel(e);
  }
});
