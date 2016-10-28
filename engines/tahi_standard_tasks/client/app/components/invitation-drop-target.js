import Ember from 'ember';
import DragNDrop from 'tahi/services/drag-n-drop';

export default Ember.Component.extend(DragNDrop.DroppableMixin, {
  classNameBindings: [':invitation-drop-target', 'validDropTarget', 'currentDropTarget'],

  DragNDrop: DragNDrop,

  currentDropTarget: false,
  isLast: false,

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

    let validPositions = DragNDrop.dragItem.get('validNewPositionsForInvitation');
    let currentPosition = DragNDrop.dragItem.get('position');

    let validIndices = validPositions.map((p) => {
      if (p < currentPosition) {
        return p;
      } else {
        return p + 1;
      }
    });

    return validIndices.includes(this.get('index'));
  }),

  drop(e) {
    this.set('currentDropTarget', false);
    if(this.get('validDropTarget')) {
      // if the new position is higher than current, decrement that new position
      // by 1 first, but not if it's the last item. acts_as_list needs to receive
      // a position that's 1 higher than the last position in order to properly move
      // something to the bottom of the list
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
