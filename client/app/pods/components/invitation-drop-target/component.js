/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

import Ember from 'ember';
import DragNDrop from 'tahi/pods/drag-n-drop/service';

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
