# How to Use

Draggable Component:

```
import Ember from 'ember';
import DragNDrop from 'tahi/services/drag-n-drop';

export default Ember.Component.extend(DragNDrop.DraggableMixin, {
  dragStart: function(e) {
    DragNDrop.dragItem = this.get('model');
  }
});
```

Droppable Component:

```
import Ember from 'ember';
import DragNDrop from 'tahi/services/drag-n-drop';

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
    DragNDrop.dragItem = null;
    // Prevent bubblbing:
    return DragNDrop.cancel(e);
  }
});
```

If applying a class on `dragOver` you'll want to remove that class in `dragLeave`, `dragEnd`, and `drop`. One or more of these events will fire but it's hard to know which ones.


# How it Works

1. Drag event -> Set DragNDrop.dragItem
1. Drop event -> Send DragNDrop.dragItem through action

# Properties

## dragItem

```
DragNDrop.dragItem(thing);
```

**thing (whatever you want!)**

*String, array, Ember class, whatever. Used to pass data from drag object to drop object.*

# Methods

## cancel

```
return DragNDrop.cancel(event);
```

**event (event)**

*Prevent drop event from bubbling. Use as last statement and return.*


## dragStart

```
dragStart: function(e) {
  DragNDrop.dragItem = @get('model');
}
```

## dragOver

```
dragStart: function(e) {
  // apply drag styles
}
```

## dragLeave / dragEnd

```
dragStart: function(e) {
  // remove styles applied from `dragOver`
}
```

## drop

```
drop: function(e) {
  this.sendAction('somethingImportant', DragNDrop.dragItem);
  return DragNDrop.cancel(event);
}
```