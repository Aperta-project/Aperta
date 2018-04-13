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

/**
  ## How to Use


  Draggable Component:

  ```
  import Ember from 'ember';
  import DragNDrop from 'tahi/pods/drag-n-drop/service';

  export default Ember.Component.extend(DragNDrop.DraggableMixin, {
    dragStart: function(e) {
      DragNDrop.set('dragItem', this.get('model'));

      // REQUIRED for Firefox to let something drag
      // http://html5doctor.com/native-drag-and-drop
      e.dataTransfer.setData('Text', 'something');
    }
  });
  ```

  Droppable Component:

  ```
  import Ember from 'ember';
  import DragNDrop from 'tahi/pods/drag-n-drop/service';

  export default Ember.Component.extend(DragNDrop.DroppableMixin, {
    removeDragStyles: function() {
      this.$().removeClass('current-drop-target');
    },

    dragOver: function(e) {
      this.$().addClass('current-drop-target');
    }

    dragLeave: function(e) {
      this.removeDragStyles();
    },

    dragEnd: function(e) {
      this.removeDragStyles();
    },

    drop: function(e) {
      this.removeDragStyles();
      this.sendAction('somethingImportant', DragNDrop.dragItem);
      // Cleanup:
      DragNDrop.set('dragItem', null);
      // Prevent bubblbing:
      return DragNDrop.cancel(e);
    }
  });
  ```

  If applying a class on `dragOver` you'll want to remove that class in `dragLeave`, `dragEnd`, and `drop`.
  One or more of these events will fire but it's hard to know which ones.

  ## How it Works

  1. Drag event -> Set DragNDrop.dragItem
  1. Drop event -> Send DragNDrop.dragItem through action
*/

const cancelDragEvent = function(e) {
  e.preventDefault();
  e.stopPropagation();
  return false;
};

const {
  Mixin,
  on
} = Ember;

export default Ember.Object.create({
  /**
    @property dragItem
    @type Whatever String, array, Ember class, whatever. Used to pass data from drag object to drop object.
    @default null
  */

  dragItem: null,

  /**
    Cancel event

    ```
    DragNDrop.cancel(event);
    ```

    @method cancel
    @param {Object} event jQuery event to stop
  */

  cancel(e) {
    return cancelDragEvent(e);
  },

  DraggableMixin: Mixin.create({
    attributeBindings: ['draggable'],
    draggable: true,

    /**
      ```
      dragStart: function(e) {
        DragNDrop.set('dragItem', this.get('model'));

        // REQUIRED for Firefox to let something drag
        // http://html5doctor.com/native-drag-and-drop
        e.dataTransfer.setData('Text', 'something');
      }
      ```

      @method dragStart
      @param {Object} event jQuery event
    */

    dragStart() { throw new Error('Implement dragStart'); }
  }),

  DroppableMixin: Mixin.create({
    /**
      Prevent annoying HTML5 drag-n-drop nonsense

      @private
      @method _dragEnter
      @param {Object} event jQuery event to stop
      @return {Boolean} false
    */
    _dragEnter: on('dragEnter', function(e) {
      return cancelDragEvent(e);
    }),

    /**
      Prevent annoying HTML5 drag-n-drop nonsense

      @private
      @method _dragOver
      @param {Object} event jQuery event to stop
      @return {Boolean} false
    */

    _dragOver: on('dragOver', function(e) {
      return cancelDragEvent(e);
    }),

    /**
      Catch drop event

      ```
      drop: function(e) {
        this.sendAction('somethingImportant', DragNDrop.dragItem);
        return DragNDrop.cancel(event);
      }
      ```

      @method drop
      @param {Object} event jQuery
    */

    drop() { throw new Error('Implement drop'); }
  })
});
