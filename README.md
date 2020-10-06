# Kkubby

Rails app that helps you organize your beauty products using shelves. Search for products from the supported catalogs (Peach & lily, Sephora, Soko Glam, SkinCeuticals)


# Installation

1. Setup the server with nginx (https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-18-04)
1. Setup the server with RVM (https://github.com/rvm/ubuntu_rvm)
1. Setup the server with nodejs and npm (sudo apt-get install nodejs yarn npm && npm install --global yarn) for webpacker
1. Setup server with nvm to install correct node JS version (https://phoenixnap.com/kb/update-node-js-version)
1. Setup SSL with letsencrypt (https://certbot.eff.org/lets-encrypt/ubuntubionic-nginx)
1. Add the example nginx conf (.nginx.conf.example)
1. Remember to add config to shared/config/database.yml and shared/config/master.key
1. Remember to add rails env production in bashrc

### Linux Server Configuration
In order to use Apparition on a Linux server, you need to install the chrome binary and
set certain `:browser_options`.

##### Install Chrome
```
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -f ./google-chrome-stable_current_amd64.deb
```

#### Browser Options
```
Capybara.register_driver :apparition do |app|
  Capybara::Apparition::Driver.new(app, browser_options: { 'no-sandbox' => nil, 'disable-web-security' => nil, 'disable-features' => 'VizDisplayCompositor' })
end
```
This will enable visits to outside websites.