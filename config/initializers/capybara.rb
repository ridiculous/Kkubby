require 'capybara/apparition'
# Initially added to scrape sephora website
Capybara.register_driver(:phantom) { |app| Capybara::Apparition::Driver.new(app, js_errors: false, debug: false, browser_logger: nil, headless: true) }
Capybara.javascript_driver = :phantom
Capybara.ignore_hidden_elements = false
Capybara.default_max_wait_time = 10
# Match first one
Capybara.match = :one
# Don't need local server since we're scraping a remote site
Capybara.run_server = false
