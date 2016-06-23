import Ember from 'ember';
import Participants from 'tahi/mixins/components/task-participants';

export default Ember.Component.extend(Participants, {
  store: Ember.inject.service(),
  to: 'overlay-drop-zone',

  /**
   *  Method called after out animation is complete.
   *  This should be set to an action.
   *  This method is passed to `overlay-animate`
   *
   *  @method outAnimationComplete
   *  @required
  **/
  outAnimationComplete: null,

  /**
   *  Toggle insertion of overlay into DOM
   *
   *  @property visible
   *  @type Boolean
   *  @default false
   *  @required
  **/
  visible: false,

  init() {
    this._super(...arguments);
    Ember.assert(
      'You must provide an outAnimationComplete action to OverlayTaskComponent',
      !Ember.isEmpty(this.get('outAnimationComplete'))
    );
  },

  actions: {
    postComment(body) {
      return this.get('store').createRecord('comment', {
        commenter: this.currentUser,
        task: this.get('task'),
        body: body,
        createdAt: new Date()
      }).save();
    }
  }
});

