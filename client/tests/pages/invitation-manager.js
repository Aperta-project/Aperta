import {
  clickable,
  collection,
  create,
  isVisible,
  property
} from 'ember-cli-page-object';

export default create({
  allInvitationsDraggable() {
    return this.invitations().mapBy('draggable').every((i) => i === true );
  },

  noInvitationsDraggable() {
    return this.invitations().mapBy('draggable').every((i) => i === false );
  },

  invitations: collection({
    itemScope: '.invitation-item',

    item: {
      draggable: property('draggable'),
      toggleExpand: clickable('.invitation-item-header'),
      isExpanded: isVisible('.invitation-item-details')
    }
  })
});
