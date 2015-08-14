import Ember from 'ember';
import PositionNearMixin from 'tahi/mixins/components/position-near';

const { computed } = Ember;

export default Ember.Component.extend(PositionNearMixin, {
  positionNearSelector: computed.alias('selector')
});
