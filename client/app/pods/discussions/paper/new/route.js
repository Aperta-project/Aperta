import DiscussionsNewRouteMixin from 'tahi/mixins/discussions/new/route';
import AuthorizedRoute from 'tahi/routes/authorized';

export default AuthorizedRoute.extend(DiscussionsNewRouteMixin, {
  paperModel(){
    return this.modelFor('discussions.paper');
  },

  // required to generate route paths:
  makeBasePath() {
    return 'discussions.paper';
  },

  setupAtMentionables(controller) {
    const paper = this.paperModel();
    paper.atMentionableStaffUsers().then(function(value){
      controller.set('atMentionableStaffUsers', value);
    });
  },

  activate() {
    this.send('updateRoute', 'new');
    this.send('updateDiscussionId', this.get('modelId'));
  }
});
