ETahi.RailsFormView = Em.View.extend
  templateName: 'components/rails_form'
  classNames: ['hi']
  focusOut: (e)->
    console.log "FOCUSING OUT!", arguments
