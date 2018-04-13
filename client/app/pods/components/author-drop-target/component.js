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
