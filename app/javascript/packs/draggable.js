export function Draggable() {
  window.zIndex = window.zIndex || 1000;
  window.moveTimer = window.moveTimer || 0;

  this.TouchHandler = function () {
    let self = this;
    let startX, startY, currentTarget;
    let siblings = {};
    let newSiblings = {};

    function nearbyProducts(touchEvent, offsetX, offsetY) {
      let imageOffsetLeft = offsetX + currentTarget.offsetLeft + currentTarget.offsetParent.offsetLeft + currentTarget.offsetParent.offsetParent.offsetLeft;
      let imageOffsetRight = imageOffsetLeft + currentTarget.offsetWidth;
      let pageY = touchEvent.clientY + offsetY;
      let padding = 10;
      let element = document.elementFromPoint(imageOffsetRight + padding, pageY);
      let leftElement = document.elementFromPoint(imageOffsetLeft - padding, pageY);
      let result = {left: null, right: null};
      let eligibleProduct = function (el) {
        return el && el.classList.contains('product-img') && currentTarget.id !== el.id && currentTarget.parentElement.parentElement.parentElement === el.parentElement.parentElement.parentElement
      };
      currentTarget.parentElement.parentElement.parentElement.querySelectorAll('.product-img').forEach(function (element) {
        element.classList.remove('nearby-target')
      });
      if (eligibleProduct(element)) {
        element.classList.add('nearby-target');
        result.right = element;
      }
      if (eligibleProduct(leftElement)) {
        leftElement.classList.add('nearby-target');
        result.left = leftElement
      }
      return result;
    }

    function initSiblings(touchEvent) {
      let images = nearbyProducts(touchEvent, 0, 0);
      siblings = {};
      newSiblings = {};
      Object.assign(siblings, images);
      Object.assign(newSiblings, images);
    };

    function insertTarget(element, handler) {
      let currentItem = currentTarget.parentElement.parentElement;
      let sibling = element.parentElement.parentElement;
      let list = currentTarget.parentElement.parentElement.parentElement;
      list.removeChild(currentItem);
      handler(list, currentItem, sibling);
      startX = null;
      startY = null;
      // persist change to server
    }

    this.touchStart = function (event) {
      event.preventDefault();
      window.moveTimer = setTimeout(function () {
        startX = startX ? startX : event.targetTouches[0].pageX;
        startY = startY ? startY : event.targetTouches[0].pageY;
        currentTarget = event.targetTouches[0].target;
        initSiblings(event.targetTouches[0]);
        currentTarget.style.zIndex = (window.zIndex++).toString();
        currentTarget.classList.add('icon-shade');
        document.body.classList.add('touch-start');
        currentTarget.addEventListener('touchmove', self.touchMove, {passive: true});
      }, 300);
    };

    this.touchEnd = function (event) {
      event.preventDefault();
      clearTimeout(window.moveTimer);
      document.body.classList.remove('touch-start');
      if (currentTarget) {
        currentTarget.classList.remove('icon-shade');
        currentTarget.removeEventListener('touchmove', self.touchMove);
        currentTarget.style.transform = '';
        document.querySelectorAll('.nearby-target').forEach(function (element) {
          element.classList.remove('nearby-target')
        });
        if (newSiblings.left) {
          if (!siblings.left || newSiblings.left.id !== siblings.left.id) {
            insertTarget(newSiblings.left, function (list, item, sibling) {
              if (sibling.nextElementSibling) {
                list.insertBefore(item, sibling.nextElementSibling);
              } else {
                list.appendChild(item);
              }
            });
          }
        } else if (newSiblings.right) {
          if (!siblings.right || newSiblings.right.id !== siblings.right.id) {
            insertTarget(newSiblings.right, function (list, item, sibling) {
              if (sibling) {
                list.insertBefore(item, sibling);
              }
            });
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
      clearTimeout(window.moveTimer);
      document.body.classList.remove('touch-start');
      if (currentTarget) {
        currentTarget.classList.remove('icon-shade');
        currentTarget.removeEventListener('touchmove', self.touchMove);
      }
    };
  };
}
