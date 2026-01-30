# Cloudinary Setup Instructions

## Where to Place Cloudinary Credentials

Your Cloudinary credentials should be added to the **.env** file in the root of your Rails project.

### Step 1: Get Your Cloudinary Credentials

1. Go to [Cloudinary Dashboard](https://cloudinary.com/console)
2. Sign up for a free account if you don't have one
3. In your dashboard, you'll see:
   - **Cloud name**: e.g., "your-cloud-name"
   - **API Key**: e.g., "123456789012345"
   - **API Secret**: e.g., "abcdefghijklmnopqrstuvwxyz"

### Step 2: Add Credentials to .env File

Open your `.env` file and add these lines at the bottom:

```bash
# Cloudinary Configuration
CLOUDINARY_CLOUD_NAME=your_cloud_name_here
CLOUDINARY_API_KEY=your_api_key_here
CLOUDINARY_API_SECRET=your_api_secret_here
CLOUDINARY_UPLOAD_FOLDER=ecommerce_products
```

Example:
```bash
CLOUDINARY_CLOUD_NAME=demo123
CLOUDINARY_API_KEY=123456789012345
CLOUDINARY_API_SECRET=abcdefghijklmnopqrstuvwxyz
CLOUDINARY_UPLOAD_FOLDER=my_ecommerce_app
```

### Step 3: Install Cloudinary Gem

Run in terminal:
```bash
bundle install
```

### Step 4: Switch to Cloudinary Storage

Edit `config/environments/development.rb`:
```ruby
config.active_storage.service = :cloudinary
```

### Step 5: Restart Rails Server

```bash
rails server
```

## Security Notes

⚠️ **IMPORTANT:**
- Never commit your `.env` file to GitHub
- Add `.env` to your `.gitignore` file
- The `.env.cloudinary.example` file shows the template structure without real credentials

## Testing the Setup

After configuration, try uploading a product image to verify it works.

