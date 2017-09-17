# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css.scss, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )


Rails.application.config.assets.precompile += %w( jquery.cookie.min.js )
Rails.application.config.assets.precompile += %w( loadmap.js )
Rails.application.config.assets.precompile += %w( media/moment_locale_de-ch.js )
Rails.application.config.assets.precompile += %w( media/datetimepicker.js )

Rails.application.config.assets.precompile += %w( imagelightbox.min.js )
Rails.application.config.assets.precompile += %w( custom_imagelightbox.js )
