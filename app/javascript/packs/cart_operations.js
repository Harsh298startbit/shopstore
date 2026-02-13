// Cart and Wishlist AJAX Operations

// Show notification function
function showNotification(message, type = 'info') {
  // Create notification element
  const notification = document.createElement('div');
  notification.className = `alert alert-${type === 'success' ? 'success' : type === 'error' ? 'danger' : 'info'} notification-toast`;
  notification.style.cssText = `
    position: fixed;
    top: 20px;
    right: 20px;
    z-index: 9999;
    min-width: 300px;
    padding: 15px 20px;
    border-radius: 4px;
    box-shadow: 0 4px 6px rgba(0,0,0,0.1);
    animation: slideInRight 0.3s ease-out;
  `;
  notification.innerHTML = `
    <button type="button" class="close" style="float: right; margin-left: 10px;">&times;</button>
    <span>${message}</span>
  `;
  
  document.body.appendChild(notification);
  
  // Close button handler
  notification.querySelector('.close').addEventListener('click', function() {
    removeNotification(notification);
  });
  
  // Auto remove after 3 seconds
  setTimeout(function() {
    removeNotification(notification);
  }, 3000);
}

function removeNotification(notification) {
  notification.style.animation = 'slideOutRight 0.3s ease-out';
  setTimeout(function() {
    if (notification.parentNode) {
      notification.parentNode.removeChild(notification);
    }
  }, 300);
}

// Add CSS animations
if (!document.getElementById('notification-styles')) {
  const style = document.createElement('style');
  style.id = 'notification-styles';
  style.textContent = `
    @keyframes slideInRight {
      from {
        transform: translateX(100%);
        opacity: 0;
      }
      to {
        transform: translateX(0);
        opacity: 1;
      }
    }
    @keyframes slideOutRight {
      from {
        transform: translateX(0);
        opacity: 1;
      }
      to {
        transform: translateX(100%);
        opacity: 0;
      }
    }
  `;
  document.head.appendChild(style);
}

// Update cart count in navigation
function updateCartCount(count) {
  const cartCountElements = document.querySelectorAll('.cart-count, .cart-badge');
  cartCountElements.forEach(function(element) {
    element.textContent = count;
    if (count > 0) {
      element.style.display = 'inline-block';
    }
  });
}

// Update cart totals on cart page
function updateCartTotals(totalItems, totalPrice) {
  // Update items count
  const itemsElement = document.querySelector('.cart-total .d-flex span:first-child');
  if (itemsElement && itemsElement.textContent === 'Items') {
    itemsElement.nextElementSibling.textContent = totalItems;
  }
  
  // Update total price
  const totalElement = document.querySelector('.cart-total .total-price span:last-child');
  if (totalElement) {
    totalElement.textContent = '$' + totalPrice.toFixed(2);
  }
  
  // Update cart count
  updateCartCount(totalItems);
}

// Update wishlist count
function updateWishlistCount() {
  // This would require an endpoint to get the wishlist count
  // For now, we'll increment/decrement if elements exist
  const wishlistCountElements = document.querySelectorAll('.wishlist-count');
  if (wishlistCountElements.length > 0) {
    // You can add an AJAX call here to get the actual count if needed
  }
}

// Setup AJAX for cart operations when DOM is ready
document.addEventListener('DOMContentLoaded', function() {
  setupCartAjax();
  setupWishlistAjax();
});

// Also setup on Turbolinks page loads
document.addEventListener('turbolinks:load', function() {
  setupCartAjax();
  setupWishlistAjax();
});

// Setup AJAX for add to cart forms
function setupCartAjax() {
  // Add to cart form on product page
  const addToCartForm = document.getElementById('add-to-cart-form');
  if (addToCartForm && !addToCartForm.dataset.ajaxSetup) {
    addToCartForm.dataset.ajaxSetup = 'true';
    addToCartForm.addEventListener('ajax:success', function(event) {
      const [data, status, xhr] = event.detail;
      eval(xhr.response);
    });
    
    addToCartForm.addEventListener('ajax:error', function(event) {
      showNotification('An error occurred. Please try again.', 'error');
    });
  }
  
  // Update quantity forms on cart page
  document.querySelectorAll('form[action*="cart_items"]').forEach(function(form) {
    if (!form.dataset.ajaxSetup) {
      form.dataset.ajaxSetup = 'true';
      
      form.addEventListener('ajax:success', function(event) {
        const [data, status, xhr] = event.detail;
        eval(xhr.response);
      });
      
      form.addEventListener('ajax:error', function(event) {
        showNotification('An error occurred. Please try again.', 'error');
      });
    }
  });
}

// Setup AJAX for wishlist operations
function setupWishlistAjax() {
  // Setup event listeners for Rails UJS
  document.querySelectorAll('a[href*="wishlist_items"][data-remote="true"]').forEach(function(link) {
    if (!link.dataset.ajaxSetup) {
      link.dataset.ajaxSetup = 'true';
      
      link.addEventListener('ajax:success', function(event) {
        const [data, status, xhr] = event.detail;
        eval(xhr.response);
      });
      
      link.addEventListener('ajax:error', function(event) {
        showNotification('An error occurred. Please try again.', 'error');
      });
    }
  });
}

// Re-initialize AJAX handlers after dynamic content load
function reinitializeAjax() {
  setupCartAjax();
  setupWishlistAjax();
}

// Export functions for use in other scripts
window.showNotification = showNotification;
window.updateCartCount = updateCartCount;
window.updateCartTotals = updateCartTotals;
window.updateWishlistCount = updateWishlistCount;
window.reinitializeAjax = reinitializeAjax;
