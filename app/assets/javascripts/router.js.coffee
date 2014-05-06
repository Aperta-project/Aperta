# For more information see: http://emberjs.com/guides/routing/
ETahi.Router.map ()->
  @route('flow_manager')
  @resource 'paper', { path: '/papers/:paper_id' }, ->
    @route('edit')
    @route('manage')
    @route('submit')

  @route('task', {path: '/papers/:paper_id/tasks/:task_id'})
  @route('paper_new', { path: '/papers/new' })
  @route('signin', {path: '/users/sign_in'})
  @route('signup', {path: '/users/sign_up'})
  @route('profile', {path: '/profile'})

  @resource('affiliation')

  @resource 'journal', path: '/admin/journals/:journal_id', ->
    @resource 'manuscript_manager_template', path: '/manuscript_manager_templates', ->
      @route('new')
      @route('edit', path: '/:template_id/edit')

ETahi.Router.reopen
  rootURL: '/'
  location: 'history'
