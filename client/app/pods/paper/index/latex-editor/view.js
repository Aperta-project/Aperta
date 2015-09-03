import Ember from 'ember';
import PaperIndexMixin from 'tahi/mixins/views/paper-index';

export default Ember.View.extend(PaperIndexMixin, {
  timeoutSave() {
    this.get('controller').send('savePaper');
  }
});
