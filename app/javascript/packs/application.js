// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
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

  let zIndex = 1000;
  let moveTimer = 0;

  document.addEventListener('scroll', function () {
    clearTimeout(moveTimer);
  });

  function TouchHandler() {
    let self = this;
    let startX, startY;
    let isMoving, currentTarget, index = 0;

    this.touchStart = function (event) {
      event.preventDefault();
      console.log(event.type, zIndex);
      moveTimer = setTimeout(function () {
        console.log("Touch activated")
        startX = startX ? startX : event.targetTouches[0].pageX;
        startY = startY ? startY : event.targetTouches[0].pageY;
        currentTarget = event.targetTouches[0].target;
        currentTarget.classList.add('moving-target');
        currentTarget.style.zIndex = (zIndex++).toString();
        currentTarget.classList.add('icon-shade');
        document.body.classList.add('touch-start');
        currentTarget.addEventListener('touchmove', self.touchMove, {passive: true});
      }, 300);
    };

    this.touchEnd = function (event) {
      event.preventDefault();
      clearTimeout(moveTimer);
      console.log(event.type);
      document.body.classList.remove('touch-start');
      if (currentTarget) {
        currentTarget.classList.remove('moving-target');
        currentTarget.classList.remove('icon-shade');
        currentTarget.removeEventListener('touchmove', self.touchMove, {passive: true});
        if (true) {
          debugger;
          // Check if we have moved over an image to the left, by checking half of the image width
          currentTarget.style.transform = '';
          // currentTarget.parentElement.parentElement.querySelectorAll('a > img')
          // document.elementFromPoint(event.pageX+currentTarget.width/2, event.pageY)
          // var first = currentTarget.parentElement.parentElement.childNodes[3].childNodes[1]
          // currentTarget.parentElement.parentElement.childNodes[3].replaceChild(currentTarget, first)
        }
      }
    };

    this.touchMove = function (event) {
      event.preventDefault();
      console.log('moving');
      curX = event.targetTouches[0].pageX - startX;
      curY = event.targetTouches[0].pageY - startY;
      event.targetTouches[0].target.style.transform = 'translate(' + curX + 'px, ' + curY + 'px)';
    }

    this.touchCancel = function (event) {
      console.log(event.type);
      clearTimeout(moveTimer);
      document.body.classList.remove('touch-start');
      if (currentTarget) {
        console.log("Removing stuff from currentTarget")
        currentTarget.classList.remove('moving-target');
        currentTarget.classList.remove('icon-shade');
        currentTarget.removeEventListener('touchmove', self.touchMove, {passive: true});
      }
    };

    this.touchForce = function (event) {
      console.log(event.type);
    };

    this.gesture = function (event) {
      console.log(event.type);
    }
  }

  if (productImages) {
    productImages.forEach(function (element) {
      let handler = new TouchHandler();
      element.addEventListener('touchstart', handler.touchStart, {passive: true});
      element.addEventListener('touchend', handler.touchEnd, {passive: true});
      element.addEventListener('touchcancel', handler.touchCancel);
      element.addEventListener('touchforcechange', handler.touchForce);
      element.addEventListener('gesturechange', handler.gesture);
    });
  }
});
