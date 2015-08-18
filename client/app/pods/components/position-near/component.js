import Ember from 'ember';
import PositionNearMixin from 'tahi/mixins/components/position-near';

/**
 *  position-near is meant to be a light component for the position-near mixin
 *  - It is block style only (see example below)
 *  - It simply positions the contents of the block next to a DOM node
 *  - See PositionNearMixin for all options
 *
 *  @example
 *    {{#position-near positionNearSelector="#the-thing"}}
 *      Important Stuff Here
 *    {{/position-near}}
 *
 *  @class PositionNearComponent
 *  @extends Ember.Component
 *  @uses PositionNearMixin
 *  @since 1.3.0
**/

export default Ember.Component.extend(PositionNearMixin, {
  positionNearSelector: Ember.computed.alias('selector')
});
