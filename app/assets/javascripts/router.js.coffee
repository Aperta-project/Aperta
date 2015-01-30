# For more information see: http://emberjs.com/guides/routing/
ETahi.Router.map ()->
  @route('flow_manager')

  @resource 'paper', { path: '/papers/*paper_id' }, ->
    @route('edit')
    @route('manage')

  @route('task', { path: '/papers/:paper_id/tasks/:task_id' })
  @route('profile', { path: '/profile' })

  @resource('affiliation')
  @resource('author')

  @resource 'admin', ->
    @resource 'journal_user', path: '/journal_users/:journal_id'
    @resource 'journal', path: '/journals/:journal_id', ->
      @resource 'manuscript_manager_template', path: '/manuscript_manager_templates', ->
        @route('new')
        @route('edit', path: '/:template_id/edit')
      @route('flow_manager', path: '/roles/:role_id/flow_manager')

  @route('styleguide')

if window.history and window.history.pushState
  ETahi.Router.reopen
    rootURL: '/'
    location: 'history'
