# For more information see: http://emberjs.com/guides/routing/
ETahi.Router.map ()->
  @route('flow_manager')
  @resource 'paper', { path: '/papers/:paper_id' }, ->
    @route('edit')
    @route('new')
    @route('manage')
    @route('task', {path: '/tasks/:task_id'})

  @route('task', {path: '/tasks/:task_id'})

ETahi.Router.reopen({
  rootURL: '/'
  location: 'history'
})
