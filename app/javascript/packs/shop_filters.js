document.addEventListener('DOMContentLoaded', initShopFilters);
document.addEventListener('turbolinks:load', initShopFilters);

function initShopFilters() {
  const filterForm = document.getElementById('filter-form');
  const productsContainer = document.getElementById('products-container');
  
  if (!filterForm || !productsContainer) return;

  // Debounce function for search/number inputs
  function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout);
        func(...args);
      };
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
    };
  }

  // Show loading state
  function showLoading() {
    productsContainer.style.opacity = '0.5';
    productsContainer.style.pointerEvents = 'none';
  }

  // Hide loading state
  function hideLoading() {
    productsContainer.style.opacity = '1';
    productsContainer.style.pointerEvents = 'auto';
  }

  // Function to apply filters via AJAX
  function applyFilters() {
    const formData = new FormData(filterForm);
    const params = new URLSearchParams(formData);
    
    // Remove empty values
    for (let [key, value] of params.entries()) {
      if (!value) params.delete(key);
    }
    
    showLoading();
    
    // Make AJAX request
    fetch(`/shop?${params.toString()}`, {
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'Accept': 'text/javascript'
      }
    })
    .then(response => response.text())
    .then(script => {
      // Execute the returned JavaScript
      eval(script);
      hideLoading();
      
      // Update URL without page reload
      const newUrl = params.toString() ? `/shop?${params.toString()}` : '/shop';
      window.history.pushState({}, '', newUrl);
      
      // Re-attach event listeners for pagination and clear button
      attachPaginationListeners();
      attachClearButtonListener();
    })
    .catch(error => {
      console.error('Error:', error);
      hideLoading();
    });
  }

  // Attach listeners to filter inputs
  const searchInput = document.querySelector('#filter-form input[name="search"]');
  const selectInputs = filterForm.querySelectorAll('select');
  const numberInputs = filterForm.querySelectorAll('input[type="number"]');

  // Search input - debounced
  if (searchInput) {
    searchInput.addEventListener('input', debounce(applyFilters, 500));
  }

  // Select dropdowns - immediate
  selectInputs.forEach(select => {
    select.addEventListener('change', applyFilters);
  });

  // Number inputs - debounced
  numberInputs.forEach(input => {
    input.addEventListener('input', debounce(applyFilters, 800));
  });

  // Clear filters link in sidebar
  const clearFiltersLink = document.querySelector('.clear-filters-link');
  if (clearFiltersLink) {
    clearFiltersLink.addEventListener('click', function(e) {
      e.preventDefault();
      filterForm.reset();
      applyFilters();
    });
  }

  // Attach pagination click handlers
  function attachPaginationListeners() {
    const paginationLinks = document.querySelectorAll('.flickr_pagination a');
    
    paginationLinks.forEach(link => {
      link.addEventListener('click', function(e) {
        e.preventDefault();
        const url = new URL(this.href);
        const params = new URLSearchParams(url.search);
        
        // Merge with current form data
        const formData = new FormData(filterForm);
        formData.forEach((value, key) => {
          if (value) params.set(key, value);
        });
        
        showLoading();
        
        fetch(`/shop?${params.toString()}`, {
          headers: {
            'X-Requested-With': 'XMLHttpRequest',
            'Accept': 'text/javascript'
          }
        })
        .then(response => response.text())
        .then(script => {
          eval(script);
          hideLoading();
          
          // Update URL
          window.history.pushState({}, '', `/shop?${params.toString()}`);
          
          // Scroll to products
          productsContainer.scrollIntoView({ behavior: 'smooth', block: 'start' });
          
          // Re-attach listeners
          attachPaginationListeners();
          attachClearButtonListener();
        })
        .catch(error => {
          console.error('Error:', error);
          hideLoading();
        });
      });
    });
  }

  // Attach clear button listener (for "No products found" message)
  function attachClearButtonListener() {
    const clearBtn = document.querySelector('.clear-filters-btn');
    if (clearBtn) {
      clearBtn.addEventListener('click', function() {
        filterForm.reset();
        applyFilters();
      });
    }
  }

  // Initial attachment
  attachPaginationListeners();
  attachClearButtonListener();
}
