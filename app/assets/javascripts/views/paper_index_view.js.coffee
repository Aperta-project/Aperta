ETahi.PaperIndexView = Ember.View.extend ETahi.RedirectsIfEditable,
  subNavVisible: false
  downloadsVisible: false
  contributorsVisible: false

  applyManuscriptCss:(->
    $('#paper-body').attr('style', @get('controller.model.journal.manuscriptCss'))
  ).on('didInsertElement')

  setBackgroundColor: (->
    $('.main-content').addClass 'matte paper-submitted'
  ).on('didInsertElement')

  resetBackgroundColor: (->
    $('.main-content').removeClass 'matte paper-submitted'
  ).on('willDestroyElement')

  subNavVisibleDidChange: (->
    if @get 'subNavVisible'
      $('.oo-ui-toolbar').css 'top', '103px'
      $('#tahi-container').addClass 'sub-nav-visible'
    else
      $('.oo-ui-toolbar').css 'top', '60px'
      $('#tahi-container').removeClass 'sub-nav-visible'
  ).observes('subNavVisible')

  actions:
    showSubNav: (sectionName)->
      if @get('subNavVisible') and @get("#{sectionName}Visible")
        @send 'hideSubNav'
      else
        @set 'subNavVisible', true
        @send "show#{sectionName.capitalize()}"

    hideSubNav: ->
      @setProperties
        subNavVisible: false
        contributorsVisible: false
        downloadsVisible: false

    showContributors: ->
      @set 'contributorsVisible', true
      @set 'downloadsVisible', false

    showDownloads: ->
      @set 'contributorsVisible', false
      @set 'downloadsVisible', true
