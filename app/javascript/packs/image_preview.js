// Image preview functionality for product form
document.addEventListener('turbolinks:load', function() {
  const imageInput = document.querySelector('#product_image');
  const imagePreview = document.getElementById('image-preview');
  const previewImg = document.getElementById('preview-img');
  const removeImageBtn = document.getElementById('remove-image');
  
  // Only initialize if elements exist
  if (!imageInput || !imagePreview || !previewImg) {
    return;
  }
  
  // Function to handle file selection
  imageInput.addEventListener('change', function(e) {
    const file = e.target.files[0];
    
    if (file) {
      // Validate file type
      const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/gif'];
      if (!allowedTypes.includes(file.type)) {
        alert('Please select a valid image file (JPEG, PNG, WebP, or GIF)');
        this.value = '';
        return;
      }
      
      // Validate file size (5MB max)
      const maxSize = 5 * 1024 * 1024; // 5MB in bytes
      if (file.size > maxSize) {
        alert('File size must be less than 5MB');
        this.value = '';
        return;
      }
      
      // Show preview
      const reader = new FileReader();
      reader.onload = function(e) {
        previewImg.src = e.target.result;
        imagePreview.style.display = 'block';
        
        // Hide existing image section if present
        const existingImage = document.getElementById('existing-image');
        if (existingImage) {
          existingImage.style.display = 'none';
        }
      };
      reader.readAsDataURL(file);
    } else {
      imagePreview.style.display = 'none';
      previewImg.src = '';
    }
  });
  
  // Function to remove image
  if (removeImageBtn) {
    removeImageBtn.addEventListener('click', function() {
      imageInput.value = '';
      previewImg.src = '';
      imagePreview.style.display = 'none';
      
      // Show existing image section if it was hidden
      const existingImage = document.getElementById('existing-image');
      if (existingImage) {
        existingImage.style.display = 'block';
      }
    });
  }
  
  // Check if we need to show existing image on page load
  const existingImage = document.getElementById('existing-image');
  const hasFileInput = imageInput && imageInput.files && imageInput.files.length > 0;
  
  if (existingImage && !hasFileInput) {
    existingImage.style.display = 'block';
  }
});

