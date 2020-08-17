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
    , productImages = document.querySelectorAll('.draggable .product-img');

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
    let startX, startY, currentTarget;
    let siblings = {};
    let newSiblings = {};

    // * VISUAL IMAGE TRACKING
    // let leftIcon = document.getElementById('leftIcon');
    // let rightIcon = document.getElementById('rightIcon');
    // leftIcon.style.left = imageOffsetLeft + 'px';
    // leftIcon.style.top = pageY + 'px';
    // rightIcon.style.left = imageOffsetRight + 'px';
    // rightIcon.style.top = pageY + 'px';
    // rightIcon.display = 'block';
    // leftIcon.display = 'block';
    function nearbyProducts(touchEvent, offsetX, offsetY) {
      let imageOffsetLeft = offsetX + currentTarget.offsetLeft + currentTarget.offsetParent.offsetLeft + currentTarget.offsetParent.offsetParent.offsetLeft;
      let imageOffsetRight = imageOffsetLeft + currentTarget.offsetWidth;
      let pageY = touchEvent.pageY + offsetY;
      let element = document.elementFromPoint(imageOffsetRight + 10, pageY);
      let leftElement = document.elementFromPoint(imageOffsetLeft - 10, pageY);
      let result = {};
      let eligibleProduct = function (el) {
        return el && el.classList.contains('product-img') && currentTarget.parentElement.parentElement.parentElement === el.parentElement.parentElement.parentElement
      };
      if (eligibleProduct(element)) result.right = element;
      if (eligibleProduct(leftElement)) result.left = leftElement;
      return result;
    }

    function initSiblings(touchEvent) {
      let images = nearbyProducts(touchEvent, 0, 0);
      Object.assign(siblings, images);
      Object.assign(newSiblings, images);
    };

    function insertTarget(element) {
      let currentItem = currentTarget.parentElement.parentElement;
      let sibling = element.parentElement.parentElement;
      let list = currentTarget.parentElement.parentElement.parentElement;
      list.removeChild(currentItem);
      if (sibling.nextElementSibling) {
        list.insertBefore(currentItem, sibling.nextElementSibling);
      } else {
        list.appendChild(currentItem);
      }
      startX = null;
      startY = null;
    };

    this.touchStart = function (event) {
      event.preventDefault();
      moveTimer = setTimeout(function () {
        startX = startX ? startX : event.targetTouches[0].pageX;
        startY = startY ? startY : event.targetTouches[0].pageY;
        currentTarget = event.targetTouches[0].target;
        initSiblings(event.targetTouches[0]);
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
      document.body.classList.remove('touch-start');
      if (currentTarget) {
        currentTarget.classList.remove('moving-target');
        currentTarget.classList.remove('icon-shade');
        currentTarget.removeEventListener('touchmove', self.touchMove);
        currentTarget.style.transform = '';
        if (newSiblings.left) {
          if (!siblings.left || newSiblings.left.id !== siblings.left.id) {
            insertTarget(newSiblings.left);
          }
        }
      }
    };

    this.touchMove = function (event) {
      event.preventDefault();
      let curX = event.targetTouches[0].pageX - startX;
      let curY = event.targetTouches[0].pageY - startY;
      document.body.classList.remove('touch-start');
      Object.assign(newSiblings, nearbyProducts(event.targetTouches[0], curX, curY));
      document.body.classList.add('touch-start');
      event.targetTouches[0].target.style.transform = 'translate(' + curX + 'px, ' + curY + 'px)';
    };

    this.touchCancel = function () {
      clearTimeout(moveTimer);
      document.body.classList.remove('touch-start');
      if (currentTarget) {
        currentTarget.classList.remove('moving-target');
        currentTarget.classList.remove('icon-shade');
        currentTarget.removeEventListener('touchmove', self.touchMove);
      }
    };
  }

  productImages.forEach(function (element) {
    let handler = new TouchHandler();
    element.addEventListener('touchstart', handler.touchStart, {passive: true});
    element.addEventListener('touchend', handler.touchEnd, {passive: true});
    element.addEventListener('touchcancel', handler.touchCancel);
  });
});
