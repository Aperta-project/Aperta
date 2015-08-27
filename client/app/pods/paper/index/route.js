import PaperEditRoute from 'tahi/pods/paper/edit/route';

export default PaperEditRoute.extend({
  redirect() {
    this.transitionTo('paper.edit');
  }
});
