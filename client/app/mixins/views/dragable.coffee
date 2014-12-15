`import Ember from 'ember'`

Dragable = Ember.Mixin.create
  attributeBindings: 'draggable'
  draggable: 'true'
  dragStart: (e) -> throw "Implement dragStart"

`export default Dragable`
