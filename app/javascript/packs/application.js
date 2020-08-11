// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")
require("turbolinks").start()

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)
document.addEventListener('turbolinks:load', function () {
  var newShelf = document.querySelector('.add-new-shelf')
    , shelfNames = document.querySelectorAll('.shelf-name > span')
    , shelfNameInputs = document.querySelectorAll('.shelf-name input[type=text]')
    , productImages = document.querySelectorAll('.product-img');

  if (newShelf) {
    newShelf.addEventListener('click', function () {
      document.querySelector('.add-new-shelf-text').style.display = 'none';
      document.querySelector('.add-new-shelf-form').style.display = 'block';
      this.classList.remove('add-new-shelf');
      document.getElementById('new_shelf_name').focus();
    });
  }

  if (shelfNames) {
    shelfNames.forEach(function (element) {
      element.addEventListener('click', function () {
        this.style.display = 'none';
        this.nextElementSibling.style.display = 'block';
        this.nextElementSibling.querySelector('input[type=text]').focus();
      });
    });
  }

  if (shelfNameInputs) {
    shelfNameInputs.forEach(function (element) {
      element.addEventListener('blur', function () {
        this.parentElement.style.display = 'none';
        this.parentElement.previousElementSibling.style.display = 'initial';
      });
    });
  }

  if (productImages) {
    productImages.forEach(function (element) {
      console.log('adding event listener')
      element.addEventListener('touchstart', function (event) {
        console.log(event.type)
      })
    });
  }
});
