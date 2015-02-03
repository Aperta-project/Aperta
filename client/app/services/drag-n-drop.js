import Ember from 'ember';

var cancelDragEvent = function(e) {
  e.preventDefault();
  e.stopPropagation();
  return false;
};

export default {
  dragItem: null,

  cancel: function(e) {
    return cancelDragEvent(e);
  },

  DraggableMixin: Ember.Mixin.create({
    attributeBindings: ['draggable'],
    draggable: true,
    dragStart: function() { throw new Error("Implement dragStart"); }
  }),

  DroppableMixin: Ember.Mixin.create({
    _dragEnter: function(e) {
      return cancelDragEvent(e);
    }.on('dragEnter'),

    _dragOver: function(e) {
      return cancelDragEvent(e);
    }.on('dragOver'),

    drop: function() { throw new Error("Implement drop"); }
  })
};
