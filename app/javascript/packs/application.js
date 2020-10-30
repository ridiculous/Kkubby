// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start();
require("turbolinks").start();
require("@rails/activestorage").start();
import {Draggable} from './draggable'

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)
window.visitPage = function (url) {
  if (typeof Turbolinks === 'object') {
    Turbolinks.visit(url)
  } else {
    window.location = url
  }
};

document.addEventListener('turbolinks:load', function () {
  let newShelf = document.querySelector('.add-new-shelf')
    , signedIn = document.querySelector('body.user-signed-in')
    , shelfNames = signedIn && document.querySelectorAll('.shelves .editable-shelf-name')
    , shelfNameInputs = signedIn && document.querySelectorAll('.shelf-name input[type=text]')
    , productImages = document.querySelectorAll('.shelves .product-img')
    , panda = signedIn && document.querySelector('.top-bar .hamburger a')
    , profileModal = document.querySelector('.profile-modal')
    , userForm = signedIn && document.querySelector('form.edit_user')
    , productSearchResults = document.querySelectorAll('.user-select-product')
    , draggable = new Draggable;

  if (newShelf) {
    newShelf.addEventListener('click', function () {
      document.querySelector('.add-new-shelf-text').style.display = 'none';
      document.querySelector('.add-new-shelf-form').style.display = 'block';
      this.classList.remove('add-new-shelf');
      document.getElementById('new_shelf_name').focus();
    });
  }

  if (shelfNames) {
    for (let i = 0; i < shelfNames.length; i++) {
      shelfNames[i].addEventListener('click', function () {
        this.style.display = 'none';
        this.nextElementSibling.style.display = 'block';
        this.nextElementSibling.querySelector('input[type=text]').focus();
      });
    }
  }

  if (shelfNameInputs) {
    for (let i = 0; i < shelfNameInputs.length; i++) {
      shelfNameInputs[i].addEventListener('blur', function () {
        this.parentElement.style.display = 'none';
        this.parentElement.previousElementSibling.style.display = 'initial';
      });
    }
  }

  function visitProductPage(event) {
    let url = event.target.parentElement.getAttribute('data-href');
    if (!url) return false;
    window.visitPage(url);
  }

  for (let i = 0; i < productImages.length; i++) {
    let element = productImages[i];
    if (signedIn) {
      let handler = new draggable.TouchHandler();
      // Mobile
      element.addEventListener('touchstart', handler.touchStart, { passive: true });
      element.addEventListener('touchend', handler.touchEnd, { passive: true });
      element.addEventListener('touchcancel', handler.touchCancel);
      // Desktop
      element.addEventListener('mousedown', handler.mouseDown);
      // Disable default browser behavior
      element.ondragstart = function () {
        return false;
      };
      element.addEventListener('click', function (event) {
        if (handler.moved) {
          event.preventDefault();
          return false;
        } else {
          visitProductPage(event);
        }
      });
    } else {
      element.addEventListener('click', visitProductPage);
    }
  }

  document.addEventListener('scroll', function () {
    clearTimeout(window.moveTimer);
  });

  if (panda) {
    panda.addEventListener('click', function (e) {
      if (profileModal.classList.contains('active')) {
        profileModal.classList.remove('active');
        document.body.classList.remove('touch-open-profile')
      } else {
        profileModal.classList.add('active');
        document.body.classList.add('touch-open-profile')
      }
      e.preventDefault();
      return false;
    });
  }

  if (userForm) {
    userForm.addEventListener('ajax:complete', function () {
      setTimeout(function () {
        document.body.classList.remove('touch-open-profile');
        profileModal.classList.remove('active');
      }, 1000)
    })
  }

  let userSelectSuccess = function (e) {
    // currently the server just redirects on success, but may hook in later
  };
  let userSelectFail = function (e) {
    e.target.classList.remove('fade');
    if (e.target.querySelector('.fade')) {
      e.target.querySelector('.fade').classList.remove('fade');
    }
    if (e.detail[0].alert) {
      let alertBox = document.querySelector(".box-type-alert");
      if (alertBox) {
        alertBox.style.display = 'none';
        setTimeout(function () {
          alertBox.innerHTML = "<b>Oops.</b> " + e.detail[0].alert;
          alertBox.style.display = 'block'
        }, 200)
      } else {
        // <div class="box-type-alert medium-major"><b>Oops.</b> Product is already on your shelf</div>
        let alertBox = document.createElement("div");
        alertBox.classList.add("box-type-alert");
        alertBox.classList.add("medium-major");
        alertBox.innerHTML = "<b>Oops.</b> " + e.detail[0].alert;
        document.body.insertBefore(alertBox, document.querySelector('#page-body'))
      }
    }
    e.preventDefault();
    return false;
  };
  for (let i = 0; i < productSearchResults.length; i++) {
    let element = productSearchResults[i];
    element.addEventListener('ajax:success', userSelectSuccess);
    element.addEventListener('ajax:error', userSelectFail);
    element.addEventListener('click', function (e) {
      e.target.classList.add('fade');
      e.preventDefault();
      return false
    })
  }
});
