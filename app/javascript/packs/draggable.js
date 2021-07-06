export function Draggable() {
  window.zIndex = window.zIndex || 1000;
  window.moveTimer = window.moveTimer || 0;

  this.TouchHandler = function (debug) {
    let self = this;
    let startX, startY, currentTarget;
    let siblings = {};
    let newSiblings = {};
    let logging = !!debug;
    self.moved = false;

    function log(msg) {
      if (logging) console.log(msg)
    }

    function grab(element) {
      if (eligibleProduct(element)) {
        return element;
      }
    }

    function eligibleProduct(el) {
      return el && el.classList.contains('product-img') && currentTarget.id !== el.id && currentTarget.parentElement.parentElement === el.parentElement.parentElement
    }

    function nearbyProducts(touchEvent, offsetX, offsetY, highlight) {
      let imageOffsetLeft = offsetX + currentTarget.offsetLeft + currentTarget.offsetParent.offsetLeft + currentTarget.offsetParent.offsetParent.offsetLeft;
      let imageOffsetRight = imageOffsetLeft + currentTarget.offsetWidth;
      let pageY = touchEvent.clientY + offsetY;
      let padding = 10;
      let result = { left: null, right: null };
      currentTarget.parentElement.parentElement.querySelectorAll('.product-img').forEach(function (element) {
        element.classList.remove('nearby-target')
      });
      let rightElement = grab(document.elementFromPoint(imageOffsetRight + padding, pageY));
      // grab(document.elementFromPoint(imageOffsetRight + padding, pageY - (currentTarget.offsetHeight))) ||
      // grab(document.elementFromPoint(imageOffsetRight + padding, pageY + (currentTarget.offsetHeight)));
      if (rightElement) {
        result.right = rightElement;
        if (highlight) rightElement.classList.add('nearby-target');
      }
      let leftElement = grab(document.elementFromPoint(imageOffsetLeft - padding, pageY));
      // grab(document.elementFromPoint(imageOffsetLeft + padding, pageY - (currentTarget.offsetHeight))) ||
      // grab(document.elementFromPoint(imageOffsetLeft + padding, pageY + (currentTarget.offsetHeight)));
      if (leftElement) {
        result.left = leftElement;
        if (highlight) leftElement.classList.add('nearby-target');
      }
      return result;
    }

    function initSiblings(touchEvent) {
      let images = nearbyProducts(touchEvent, 0, 0, false);
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
        log("left sibling found");
        if (!siblings.left || newSiblings.left.id !== siblings.left.id) {
          log("Rearranging image");
          insertTarget(newSiblings.left, function (list, item, sibling) {
            if (sibling.nextElementSibling) {
              list.insertBefore(item, sibling.nextElementSibling);
            } else {
              list.appendChild(item);
            }
          });
        } else {
          // debugger;
        }
      } else if (newSiblings.right) {
        log("right sibling found");
        if (!siblings.right || newSiblings.right.id !== siblings.right.id) {
          insertTarget(newSiblings.right, function (list, item, sibling) {
            if (sibling) {
              log("Rearranging image");
              list.insertBefore(item, sibling);
            }
          });
        }
      } else {
        log("No siblings to update");
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
        startX = event.targetTouches[0].clientX;
        startY = event.targetTouches[0].clientY;
        currentTarget = event.targetTouches[0].target;
        initSiblings(event.targetTouches[0]);
        currentTarget.style.zIndex = (window.zIndex++).toString();
        currentTarget.classList.add('icon-shade');
        document.body.classList.add('touch-start');
        currentTarget.addEventListener('touchmove', self.touchMove);
      }, 300);
    };

    this.touchEnd = function (event) {
      event.preventDefault();
      log(event.type);
      clearTimeout(window.moveTimer);
      document.body.classList.remove('touch-start');
      if (!currentTarget) {
        log("No current target");
        window.visitProductPage(event);
        return;
      }
      currentTarget.classList.remove('icon-shade');
      currentTarget.removeEventListener('touchmove', self.touchMove);
      currentTarget.style.transform = '';
      resetTracers();
      updateNodePosition();
      currentTarget = null;
    };

    this.touchMove = function (event) {
      event.preventDefault();
      log(event.type);
      let curX = event.targetTouches[0].clientX - startX;
      let curY = event.targetTouches[0].clientY - startY;
      document.body.classList.remove('touch-start');
      Object.assign(newSiblings, nearbyProducts(event.targetTouches[0], curX, curY, true));
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
      self.moved = true;
      Object.assign(newSiblings, nearbyProducts(event, curX, curY, true));
      currentTarget.style.transform = 'translate(' + curX + 'px, ' + curY + 'px)';
    };

    this.mouseDown = function (event) {
      log(event.type);
      self.moved = false;
      if (event.which === 3) return true;
      currentTarget = event.target;
      startX = event.clientX;
      startY = event.clientY;
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
      document.removeEventListener('mouseup', self.mouseUp);
      resetTracers();
      updateNodePosition();
    }
  };
}
