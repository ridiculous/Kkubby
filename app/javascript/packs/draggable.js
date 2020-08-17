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
    }

    this.touchStart = function (event) {
      event.preventDefault();
      window.moveTimer = setTimeout(function () {
        startX = startX ? startX : event.targetTouches[0].pageX;
        startY = startY ? startY : event.targetTouches[0].pageY;
        currentTarget = event.targetTouches[0].target;
        initSiblings(event.targetTouches[0]);
        currentTarget.classList.add('moving-target');
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
      clearTimeout(window.moveTimer);
      document.body.classList.remove('touch-start');
      if (currentTarget) {
        currentTarget.classList.remove('moving-target');
        currentTarget.classList.remove('icon-shade');
        currentTarget.removeEventListener('touchmove', self.touchMove);
      }
    };
  }

  // * VISUAL IMAGE TRACKING
  // let leftIcon = document.getElementById('leftIcon');
  // let rightIcon = document.getElementById('rightIcon');
  // leftIcon.style.left = imageOffsetLeft + 'px';
  // leftIcon.style.top = pageY + 'px';
  // rightIcon.style.left = imageOffsetRight + 'px';
  // rightIcon.style.top = pageY + 'px';
  // rightIcon.display = 'block';
  // leftIcon.display = 'block';
}
