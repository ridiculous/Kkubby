export function Draggable() {
  window.zIndex = window.zIndex || 1000;
  window.moveTimer = window.moveTimer || 0;

  this.TouchHandler = function () {
    let self = this;
    let startX, startY, currentTarget;
    let siblings = {};
    let newSiblings = {};
    let logging = true;

    function log(msg) {
      if (logging) console.log(msg)
    }

    function nearbyProducts(touchEvent, offsetX, offsetY) {
      let imageOffsetLeft = offsetX + currentTarget.offsetLeft + currentTarget.offsetParent.offsetLeft + currentTarget.offsetParent.offsetParent.offsetLeft;
      let imageOffsetRight = imageOffsetLeft + currentTarget.offsetWidth;
      let pageY = touchEvent.clientY + offsetY;
      let padding = 10;
      let element = document.elementFromPoint(imageOffsetRight + padding, pageY);
      let leftElement = document.elementFromPoint(imageOffsetLeft - padding, pageY);
      let result = { left: null, right: null };
      let eligibleProduct = function (el) {
        return el && el.classList.contains('product-img') && currentTarget.id !== el.id && currentTarget.parentElement.parentElement === el.parentElement.parentElement
      };
      currentTarget.parentElement.parentElement.querySelectorAll('.product-img').forEach(function (element) {
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
      let currentItem = currentTarget.parentElement;
      let sibling = element.parentElement;
      let list = currentTarget.parentElement.parentElement;
      list.removeChild(currentItem);
      handler(list, currentItem, sibling);
      startX = null;
      startY = null;
      persistChange(list);
    }

    function updateNodePosition() {
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

    function resetTracers() {
      document.querySelectorAll('.nearby-target').forEach(function (element) {
        element.classList.remove('nearby-target')
      });
    }

    function persistChange(list) {
      let xhr = new XMLHttpRequest();
      let items = [];
      list.querySelectorAll('li').forEach(function (li) {
        items.push(li.id)
      });
      xhr.open('PUT', '/update_product_order', true);
      xhr.setRequestHeader("Content-type", "application/json");
      xhr.send(JSON.stringify({
        shelf_id: list.id,
        products: items,
        authenticity_token: document.head.querySelector('meta[name="csrf-token"]').content
      }));
    }

    this.touchStart = function (event) {
      event.preventDefault();
      log(event.type);
      window.moveTimer = setTimeout(function () {
        startX = startX ? startX : event.targetTouches[0].clientX;
        startY = startY ? startY : event.targetTouches[0].clientY;
        currentTarget = event.targetTouches[0].target;
        initSiblings(event.targetTouches[0]);
        currentTarget.style.zIndex = (window.zIndex++).toString();
        currentTarget.classList.add('icon-shade');
        document.body.classList.add('touch-start');
        currentTarget.addEventListener('touchmove', self.touchMove, { passive: true });
      }, 300);
    };

    this.touchEnd = function (event) {
      event.preventDefault();
      log(event.type);
      clearTimeout(window.moveTimer);
      document.body.classList.remove('touch-start');
      if (!currentTarget) return true;
      currentTarget.classList.remove('icon-shade');
      currentTarget.removeEventListener('touchmove', self.touchMove);
      currentTarget.style.transform = '';
      resetTracers();
      updateNodePosition()
    };

    this.touchMove = function (event) {
      event.preventDefault();
      log(event.type);
      let curX = event.targetTouches[0].clientX - startX;
      let curY = event.targetTouches[0].clientY - startY;
      document.body.classList.remove('touch-start');
      Object.assign(newSiblings, nearbyProducts(event.targetTouches[0], curX, curY));
      document.body.classList.add('touch-start');
      event.targetTouches[0].target.style.transform = 'translate(' + curX + 'px, ' + curY + 'px)';
    };

    this.touchCancel = function (event) {
      clearTimeout(window.moveTimer);
      log(event.type);
      document.body.classList.remove('touch-start');
      if (currentTarget) {
        currentTarget.classList.remove('icon-shade');
        currentTarget.removeEventListener('touchmove', self.touchMove);
      }
    };

    this.onMouseMove = function (event) {
      log(event.type);
      let curX = event.clientX - startX;
      let curY = event.clientY - startY;
      Object.assign(newSiblings, nearbyProducts(event, curX, curY));
      currentTarget.style.transform = 'translate(' + curX + 'px, ' + curY + 'px)';
    };

    this.mouseDown = function (event) {
      log(event.type);
      currentTarget = event.target;
      startX = startX ? startX : event.clientX;
      startY = startY ? startY : event.clientY;
      initSiblings(event);
      currentTarget.style.zIndex = (window.zIndex++).toString();
      currentTarget.classList.add('icon-shade');
      document.addEventListener('mouseup', self.mouseUp);
      document.addEventListener('mousemove', self.onMouseMove);
    };

    this.mouseUp = function (event) {
      log(event.type);
      currentTarget.classList.remove('icon-shade');
      currentTarget.style.transform = '';
      document.removeEventListener('mousemove', self.onMouseMove);
      resetTracers();
      updateNodePosition();
    }
  };
}
