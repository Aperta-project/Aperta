export function initialize(applicationInstance) {
  const currentUser = applicationInstance.lookup('user:current');
  if (currentUser && typeof window.FS !== 'undefined') {
    window.FS.identify(currentUser.get('username'), {
      displayName: currentUser.get('fullName'),
      email: currentUser.get('email')
    });
  }
}

export default {
  name: 'full-story-config',
  after: 'current-user',
  initialize
};
