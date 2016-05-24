Rails.application.config.assets.version = '1.0'

Rails.application.config.assets.initialize_on_precompile = true
Rails.application.config.assets.precompile << /\.(?:svg|eot|woff|ttf|woff2)$/
Rails.application.config.assets.precompile += %w(email.scss auth.scss)

Rails.application.config.assets.paths << Rails.root.join('vendor', 'assets', 'stylesheets')
Rails.application.config.assets.paths << Rails.root.join('vendor', 'assets', 'images')
