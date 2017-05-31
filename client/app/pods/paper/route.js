import AuthorizedRoute from 'tahi/routes/authorized';
import PopoutParentRouteMixin from 'ember-popout/mixins/popout-parent-route';
import Ember from 'ember';

export default AuthorizedRoute.extend(PopoutParentRouteMixin,{
  channelName: null,
  popoutParams: { top: 10, left: 10, height: screen.height, width: 900 },

  model(params) {
    return this.store.query('paper', { shortDoi: params.paper_shortDoi })
    .then((results) => {
      return results.get('firstObject');
    });
  },

  serialize(model) {
    return { paper_shortDoi: model.get('shortDoi') };
  },

  setupController(controller, model) {
    this._super(...arguments);
    this.setupPusher(model);
    model.get('commentLooks');

    let popout = this.get('popoutParent');
    $(window).on('beforeunload.popout', function(){
      popout.closeAll();
    });
  },

  redirect(model, transition) {
    if (!transition.intent.url) {
      return;
    }
    var url = transition.intent.url.replace(`/papers/${model.get('id')}`, `/papers/${model.get('shortDoi')}`);
    if (url !== transition.intent.url) {
      this.transitionTo(url);
    }
  },

  setupPusher(model) {
    let pusher = this.get('pusher');
    this.set('channelName', 'private-paper@' + model.get('id'));

    // This will bubble up to created and updated actions in the root
    // application route
    pusher.wire(this, this.channelName, ['created', 'updated', 'destroyed']);
  },

  deactivate() {
    this.get('pusher').unwire(this, this.get('channelName'));

    let popout = this.get('popoutParent');
    popout.closeAll();
  },

  _pusherEventsId() {
    // needed for the `wire` and `unwire` method
    // to think we have `ember-pusher/bindings` mixed in
    return this.toString();
  },

  actions: {
    openDiscussionsPopout(options) {
      let paper = this.get('controller').model;
      let popout = this.get('popoutParent');
      if (options.discussionId === null) {
        popout.open(paper.id, options.path, paper.id, this.get('popoutParams'));
      } else {
        popout.open(paper.id, options.path, paper.id,
                    options.discussionId, this.get('popoutParams'));
      }
    },

    popInDiscussions(options) {
      let currentRoute = this.router.currentRouteName;
      let path = currentRoute.replace(/index$/, 'discussions.' + options.route);
      if (options.discussionId === null) {
        this.transitionTo(path);
      }else{
        this.transitionTo(path, options.discussionId);
      }
    },

    showOrRaiseDiscussions(path){
      let paper = this.get('controller').model;
      let popout = this.get('popoutParent');

      if (Ember.isEmpty(popout.popoutNames)){
        this.transitionTo(path);
      } else {
        popout.popouts[paper.id].focus();
      }
    }
  }
});
