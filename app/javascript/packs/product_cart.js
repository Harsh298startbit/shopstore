// Quantity increase/decrease buttons
document.addEventListener('turbolinks:load', function() {
  // Quantity controls
  const quantityInput = document.getElementById('quantity-input');
  const variantSelect = document.getElementById('variant-select');
  const stockInfo = document.getElementById('stock-info');
  
  if (quantityInput) {
    // Decrease quantity
    document.querySelectorAll('.quantity-left-minus').forEach(btn => {
      btn.addEventListener('click', function(e) {
        e.preventDefault();
        let currentVal = parseInt(quantityInput.value);
        if (currentVal > 1) {
          quantityInput.value = currentVal - 1;
        }
      });
    });
    
    // Increase quantity
    document.querySelectorAll('.quantity-right-plus').forEach(btn => {
      btn.addEventListener('click', function(e) {
        e.preventDefault();
        let currentVal = parseInt(quantityInput.value);
        quantityInput.value = currentVal + 1;
      });
    });
  }
  
  // Update stock info when variant changes
  if (variantSelect && stockInfo) {
    variantSelect.addEventListener('change', function() {
      const selectedOption = this.options[this.selectedIndex];
      const variantId = this.value;
      
      // You can make an AJAX call here to get exact stock for the variant
      // For now, just keep the existing total stock display
    });
  }
});
