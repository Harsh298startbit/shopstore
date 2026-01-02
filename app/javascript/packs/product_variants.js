// Dynamic Product Variants Management

document.addEventListener('turbolinks:load', function() {
  // Add variant button functionality
  const addVariantButton = document.getElementById('add-variant-button');
  
  if (addVariantButton) {
    addVariantButton.addEventListener('click', function(e) {
      e.preventDefault();
      
      const variantsContainer = document.getElementById('variants-container');
      const newId = new Date().getTime();
      
      // Get the first variant field as template
      const template = variantsContainer.querySelector('.variant-fields');
      if (!template) return;
      
      // Clone the template
      const newVariant = template.cloneNode(true);
      
      // Clear input values
      newVariant.querySelectorAll('input[type="text"], input[type="number"]').forEach(input => {
        input.value = '';
      });
      
      // Update field names and IDs to make them unique
      newVariant.querySelectorAll('input, select, textarea').forEach(field => {
        if (field.name) {
          // Replace the index in the name attribute
          field.name = field.name.replace(/\[product_variants_attributes\]\[\d+\]/, 
                                          `[product_variants_attributes][${newId}]`);
        }
        if (field.id) {
          field.id = field.id.replace(/_\d+_/, `_${newId}_`);
        }
      });
      
      // Remove the _destroy hidden field value
      const destroyField = newVariant.querySelector('input[name*="_destroy"]');
      if (destroyField) {
        destroyField.value = '';
      }
      
      // Append the new variant
      variantsContainer.appendChild(newVariant);
      
      // Reinitialize remove buttons
      initializeRemoveButtons();
    });
  }
  
  // Initialize remove variant buttons
  initializeRemoveButtons();
  
  function initializeRemoveButtons() {
    document.querySelectorAll('.remove-variant').forEach(button => {
      // Remove old event listeners by cloning
      const newButton = button.cloneNode(true);
      button.parentNode.replaceChild(newButton, button);
      
      newButton.addEventListener('click', function(e) {
        e.preventDefault();
        
        const variantField = this.closest('.variant-fields');
        const destroyField = variantField.querySelector('input[name*="_destroy"]');
        
        if (destroyField) {
          // If this is an existing record, mark for destruction
          const idField = variantField.querySelector('input[name*="[id]"]');
          if (idField && idField.value) {
            destroyField.value = '1';
            variantField.style.display = 'none';
          } else {
            // If it's a new record, just remove the div
            variantField.remove();
          }
        } else {
          variantField.remove();
        }
      });
    });
  }
});
