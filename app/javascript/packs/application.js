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

  let leftIcon = document.getElementById('leftIcon');
  let rightIcon = document.getElementById('rightIcon');

  function go() {
    let list = document.querySelector('.draggable-products');
    let items = list.querySelectorAll('li');
    items.forEach(function(el) {
      list.removeChild(el)
    });
    items.forEach(function(el) {
      list.appendChild(el)
    });
  }

  function TouchHandler() {
    let self = this;
    let startX, startY;
    let isMoving, currentTarget, index = 0;
    let siblings = {};
    let newSiblings = {};

    function nearbyProducts(touchEvent, offsetX, offsetY) {
      let imageOffsetLeft = currentTarget.offsetLeft + currentTarget.offsetParent.offsetLeft + currentTarget.offsetParent.offsetParent.offsetLeft;
      imageOffsetLeft += offsetX;
      let imageOffsetRight = imageOffsetLeft + currentTarget.offsetWidth;
      let pageY = touchEvent.pageY;
      pageY += offsetY;
      let element = document.elementFromPoint(imageOffsetRight + 10, pageY);
      let leftElement = document.elementFromPoint(imageOffsetLeft - 10, pageY);
      let result = {};
      // leftIcon.style.left = imageOffsetLeft + 'px';
      // leftIcon.style.top = pageY + 'px';
      // rightIcon.style.left = imageOffsetRight + 'px';
      // rightIcon.style.top = pageY + 'px';
      // rightIcon.display = 'block';
      // leftIcon.display = 'block';
      if (element && element.classList.contains('product-img')) {
        result.right = element
      }
      if (leftElement && leftElement.classList.contains('product-img')) {
        if (currentTarget.parentElement.parentElement.parentElement === leftElement.parentElement.parentElement.parentElement) {
          result.left = leftElement
        } else
          console.log("--> Found OTHER PARENT")
      }
      return result;
    }

    function initSiblings(touchEvent) {
      let images = nearbyProducts(touchEvent, 0, 0);
      Object.assign(siblings, images);
      Object.assign(newSiblings, images);
      // if (images.right) {
      //   console.log('init RIGHT: ' + images.right.id)
      //   siblings.right = images.right;
      // }
      // if (images.left) {
      //   console.log('init LEFT: ' + images.left.id);
      //   siblings.left = images.left;
      // }
    };

    function insertTarget(element) {
      var currentItem = currentTarget.parentElement.parentElement;
      var sibling = element.parentElement.parentElement;
      var list = currentTarget.parentElement.parentElement.parentElement;
      list.removeChild(currentItem);
      if (sibling.nextElementSibling) {
        try {
          list.insertBefore(currentItem, sibling.nextElementSibling);
        } catch(e) {
          debugger;
        }
      } else {
        list.appendChild(currentItem);
      }
      startX = null;
      startY = null;
      currentItem.style.display='none';
      currentItem.offsetHeight; // no need to store this anywhere, the reference is enough
      currentItem.style.display='';
    };

    this.touchStart = function (event) {
      event.preventDefault();
      console.log(event.type, zIndex);
      moveTimer = setTimeout(function () {
        console.log("Touch activated");
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
      console.log(event.type);
      document.body.classList.remove('touch-start');
      if (currentTarget) {
        currentTarget.classList.remove('moving-target');
        currentTarget.classList.remove('icon-shade');
        currentTarget.removeEventListener('touchmove', self.touchMove);
        // debugger
        if (true) {
          // debugger;
          // let element = document.elementFromPoint(event.pageX + currentTarget.width / 2, event.pageY)
          // console.log("touchend X and Y", event.pageX + currentTarget.width / 2, event.pageY)
          // if (element && element.classList.contains('product-img')) {
          //   console.log('Over image ' + element.title)
          // }
          // Check if we have moved over an image to the left, by checking half of the image width
          currentTarget.style.transform = '';
          // currentTarget.parentElement.parentElement.querySelectorAll('a > img')
          // var first = currentTarget.parentElement.parentElement.childNodes[3].childNodes[1]
          // currentTarget.parentElement.parentElement.childNodes[3].replaceChild(currentTarget, first)
          if (newSiblings.left) {
            if (!siblings.left || newSiblings.left.id != siblings.left.id) {
              console.log('Persist change to sibling: ' + newSiblings.left.id)
              insertTarget(newSiblings.left);
            }
          }
        }
      }
    };

    this.touchMove = function (event) {
      event.preventDefault();
      console.log('moving');
      curX = event.targetTouches[0].pageX - startX;
      curY = event.targetTouches[0].pageY - startY;
      document.body.classList.remove('touch-start');
      Object.assign(newSiblings, nearbyProducts(event.targetTouches[0], curX, curY));
      document.body.classList.add('touch-start');
      event.targetTouches[0].target.style.transform = 'translate(' + curX + 'px, ' + curY + 'px)';
      // let element = document.elementFromPoint(event.targetTouches[0].pageX + currentTarget.width / 2, event.targetTouches[0].pageY)
      // let leftElement = document.elementFromPoint(event.targetTouches[0].pageX - currentTarget.width / 2, event.targetTouches[0].pageY)
      // console.log('MOVE-X', event.targetTouches[0].pageX+currentTarget.width/2)
      // console.log('MOVE-Y', event.targetTouches[0].pageY)
      // console.log(element)
      // if (element && element.classList.contains('product-img')) {
      //   console.log('Image to the RIGHT: ' + element.id)
      // }
      // if (leftElement && leftElement.classList.contains('product-img')) {
      //   console.log('Image to the LEFT: ' + leftElement.id)
      // }
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
