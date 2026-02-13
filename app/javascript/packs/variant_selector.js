// Product Variant Selector

document.addEventListener('turbolinks:load', function() {
  const variantCards = document.querySelectorAll('.variant-card');
  const selectedVariantInput = document.getElementById('selected-variant-id');
  const stockInfo = document.getElementById('stock-info');
  const quantityInput = document.getElementById('quantity-input');
  const addToCartButton = document.querySelector('input[type="submit"][value="Add to Cart"]');
  
  if (variantCards.length > 0) {
    // Initialize with first variant selected
    updateVariantSelection();
    
    variantCards.forEach(card => {
      card.addEventListener('click', function() {
        // Update the radio button
        const radio = this.querySelector('input[type="radio"]');
        if (radio) {
          radio.checked = true;
          updateVariantSelection();
        }
      });
      
      // Also handle radio button change directly
      const radio = card.querySelector('input[type="radio"]');
      if (radio) {
        radio.addEventListener('change', updateVariantSelection);
      }
    });
  }
  
  function updateVariantSelection() {
    const selectedRadio = document.querySelector('input[name="variant_selection"]:checked');
    
    if (selectedRadio) {
      const variantCard = selectedRadio.closest('.variant-card');
      const variantId = variantCard.dataset.variantId;
      const price = parseFloat(variantCard.dataset.price);
      const stock = parseInt(variantCard.dataset.stock);
      
      // Update hidden field
      if (selectedVariantInput) {
        selectedVariantInput.value = variantId;
      }
      
      // Update stock info
      if (stockInfo) {
        if (stock > 0) {
          stockInfo.textContent = `${stock} units available`;
          stockInfo.style.color = stock <= 5 ? '#dc3545' : '#000';
        } else {
          stockInfo.textContent = 'Out of stock';
          stockInfo.style.color = '#dc3545';
        }
      }
      
      // Update quantity input max value
      if (quantityInput) {
        quantityInput.max = stock;
        if (parseInt(quantityInput.value) > stock) {
          quantityInput.value = Math.max(1, stock);
        }
      }
      
      // Disable add to cart if out of stock
      if (addToCartButton) {
        if (stock <= 0) {
          addToCartButton.disabled = true;
          addToCartButton.value = 'Out of Stock';
          addToCartButton.classList.add('btn-secondary');
          addToCartButton.classList.remove('btn-black');
        } else {
          addToCartButton.disabled = false;
          addToCartButton.value = 'Add to Cart';
          addToCartButton.classList.add('btn-black');
          addToCartButton.classList.remove('btn-secondary');
        }
      }
      
      // Update visual selection
      variantCards.forEach(card => {
        card.classList.remove('selected');
      });
      variantCard.classList.add('selected');
    }
  }
});
