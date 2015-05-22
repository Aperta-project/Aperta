import Ember from 'ember';
import FileUploadMixin from 'tahi/mixins/file-upload';

export default Ember.Component.extend(FileUploadMixin, {
  avatarUploadUrl: '/api/users/update_avatar',
  /**
   * @property user
   * @type {User} Ember.Data model instance
   * @default null
   * @required
   */
  user: null,
  //<validation>
  _validate_user: function() {
    Ember.assert('The `user` property must be set on the user-avatar-upload component', !Ember.isEmpty(this.get('user')));
  }.on('init'),
  //</validation>

  actions: {
    uploadFinished(data, filename) {
      this.uploadFinished(data, filename);
      this.set('user.avatarUrl', data.avatar_url);
    }
  }
});
