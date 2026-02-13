# Cloudinary Setup TODO List

## ✅ Step 1: Add Cloudinary Gem to Gemfile
- [x] Add `cloudinary` gem to Gemfile
- [x] Add `activestorage-cloudinary-service` gem

## ✅ Step 2: Configure Cloudinary Storage
- [x] Update `config/storage.yml` with Cloudinary service configuration

## ✅ Step 3: Create .env Template for Credentials
- [x] Create `.env.cloudinary.example` template
- [x] Document where to place Cloudinary credentials
- [x] Create `CLOUDINARY_SETUP.md` with detailed instructions

## ✅ Step 4: Create Image Upload Service
- [x] Create `app/services/image_service.rb`
- [x] Implement upload, validation, and transformation methods

## ✅ Step 5: Update Environment Configuration
- [x] Update `config/environments/development.rb` to use Cloudinary
- [x] Update `config/environments/production.rb` to use Cloudinary

## ✅ Step 6: Add Validations to Product Model
- [x] Add file type validation (jpg, jpeg, png, webp, gif)
- [x] Add file size validation (max 5MB)
- [x] Add custom validation methods

## ✅ Step 7: Create Cloudinary Helper
- [x] Create `app/helpers/cloudinary_helper.rb`
- [x] Add helper methods for image display

## ✅ Step 8: Update Product Views
- [x] Modify `app/views/products/show.html.erb` for Cloudinary-optimized images
- [x] Update `app/views/products/_form.html.erb` with image preview
- [x] Add image preview JavaScript in `app/javascript/packs/image_preview.js`
- [x] Update `app/views/products/new.html.erb` to include image preview JS
- [x] Update `app/views/products/edit.html.erb` to include image preview JS

## ✅ Step 9: Update Product Index View
- [ ] Update product index page to use Cloudinary card images

## 📝 Notes:
- Cloudinary credentials should be placed in `.env` file
- Never commit `.env` file to version control
- Use Cloudinary dashboard to get API credentials

## 🚀 Next Steps After Completing Setup:

1. **Install the gem:**
   ```bash
   bundle install
   ```

2. **Add your Cloudinary credentials to `.env` file:**
   ```
   CLOUDINARY_CLOUD_NAME=your_cloud_name
   CLOUDINARY_API_KEY=your_api_key
   CLOUDINARY_API_SECRET=your_api_secret
   CLOUDINARY_UPLOAD_FOLDER=ecommerce_products
   ```

3. **Switch to Cloudinary storage** (uncomment in config/environments/development.rb):
   ```ruby
   config.active_storage.service = :cloudinary
   ```

4. **Restart Rails server:**
   ```bash
   rails server
   ```

5. **Test the setup:**
   - Create a new product with an image
   - Verify the image uploads to Cloudinary
   - Check that validation works (try a non-image file)
   - Check that size validation works (try a file > 5MB)

