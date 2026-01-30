# # ImageService - Cloudinary Image Upload Service
# # Handles image uploads, validations, and transformations for Cloudinary

# class ImageService
#   # Allowed file types for image uploads
#   ALLOWED_CONTENT_TYPES = %w[
#     image/jpeg
#     image/jpg
#     image/png
#     image/webp
#     image/gif
#   ].freeze

#   # Allowed file extensions
#   ALLOWED_EXTENSIONS = %w[jpg jpeg png webp gif].freeze

#   # Maximum file size in bytes (5MB)
#   MAX_FILE_SIZE = 5.megabytes.freeze

#   # Default image transformations for different use cases
#   TRANSFORMATIONS = {
#     thumbnail: {
#       width: 150,
#       height: 150,
#       crop: :thumb,
#       gravity: :auto,
#       quality: :auto,
#       fetch_format: :auto
#     },
#     preview: {
#       width: 400,
#       height: 400,
#       crop: :limit,
#       quality: :auto,
#       fetch_format: :auto
#     },
#     main: {
#       width: 1200,
#       height: 1200,
#       crop: :limit,
#       quality: :auto,
#       fetch_format: :auto
#     },
#     card: {
#       width: 300,
#       height: 300,
#       crop: :fill,
#       gravity: :auto,
#       quality: :auto,
#       fetch_format: :auto
#     },
#     hero: {
#       width: 1920,
#       height: 1080,
#       crop: :fill,
#       gravity: :auto,
#       quality: :auto,
#       fetch_format: :auto
#     }
#   }.freeze

#   class << self
#     # Upload an image to Cloudinary
#     # @param file [ActionDispatch::Http::UploadedFile, String] - The file to upload or a remote URL
#     # @param options [Hash] - Additional upload options
#     # @return [Hash] - Cloudinary upload result
#     def upload(file, options = {})
#       return { error: 'No file provided' } if file.blank?

#       # Validate the file before upload
#       validation = validate_file(file)
#       return validation unless validation[:valid]

#       begin
#         # If it's an uploaded file, convert to Cloudinary upload
#         if file.is_a?(ActionDispatch::Http::UploadedFile)
#           result = Cloudinary::Uploader.upload(
#             file.tempfile.path,
#             build_upload_options(options)
#           )
#         elsif file.is_a?(String)
#           # Handle remote URL or existing public ID
#           result = Cloudinary::Uploader.upload(
#             file,
#             build_upload_options(options)
#           )
#         else
#           return { error: 'Invalid file type' }
#         end

#         {
#           success: true,
#           public_id: result['public_id'],
#           url: result['secure_url'],
#           width: result['width'],
#           height: result['height'],
#           format: result['format'],
#           bytes: result['bytes'],
#           result: result
#         }
#       rescue CloudinaryException => e
#         { error: "Upload failed: #{e.message}" }
#       rescue StandardError => e
#         { error: "Upload failed: #{e.message}" }
#       end
#     end

#     # Upload with specific transformation
#     # @param file [ActionDispatch::Http::UploadedFile] - The file to upload
#     # @param transformation_type [Symbol] - One of :thumbnail, :preview, :main, :card, :hero
#     # @param options [Hash] - Additional upload options
#     # @return [Hash] - Cloudinary upload result with transformed URL
#     def upload_with_transformation(file, transformation_type = :main, options = {})
#       upload(file, options.merge(
#         transformation: TRANSFORMATIONS[transformation_type]
#       ))
#     end

#     # Delete an image from Cloudinary
#     # @param public_id [String] - The public ID of the image to delete
#     # @return [Hash] - Deletion result
#     def delete(public_id)
#       return { error: 'No public_id provided' } if public_id.blank?

#       begin
#         result = Cloudinary::Uploader.destroy(public_id)
#         {
#           success: result['result'] == 'ok',
#           result: result
#         }
#       rescue CloudinaryException => e
#         { error: "Delete failed: #{e.message}" }
#       rescue StandardError => e
#         { error: "Delete failed: #{e.message}" }
#       end
#     end

#     # Generate a transformed URL for an existing image
#     # @param public_id [String] - The public ID of the image
#     # @param transformation_type [Symbol, Hash] - Transformation type or custom options
#     # @return [String] - Transformed URL or nil if invalid
#     def transformed_url(public_id, transformation_type = :main)
#       return nil if public_id.blank?

#       transformation = if transformation_type.is_a?(Symbol)
#                          TRANSFORMATIONS[transformation_type]
#                        else
#                          transformation_type
#                        end

#       Cloudinary::Utils.cloudinary_url(
#         public_id,
#         transformation: transformation
#       )
#     end

#     # Generate multiple image sizes for responsive images
#     # @param public_id [String] - The public ID of the image
#     # @return [Hash] - Hash with different size URLs
#     def responsive_urls(public_id)
#       return nil if public_id.blank?

#       {
#         thumbnail: transformed_url(public_id, :thumbnail),
#         preview: transformed_url(public_id, :preview),
#         main: transformed_url(public_id, :main),
#         card: transformed_url(public_id, :card)
#       }
#     end

#     # Validate file before upload
#     # @param file [ActionDispatch::Http::UploadedFile, String] - The file to validate
#     # @return [Hash] - Validation result with :valid boolean and :error message if invalid
#     def validate_file(file)
#       # Handle nil or blank input
#       return { valid: false, error: 'No file provided' } if file.blank?

#       # If it's a string (URL or existing public ID), skip validation
#       return { valid: true } if file.is_a?(String)

#       # Validate uploaded file
#       if file.respond_to?(:tempfile) && file.tempfile
#         # Check file size
#         file_size = file.tempfile.size
#         if file_size > MAX_FILE_SIZE
#           return {
#             valid: false,
#             error: "File size exceeds maximum allowed size of #{MAX_FILE_SIZE / 1.megabyte}MB"
#           }
#         end

#         # Check content type
#         unless ALLOWED_CONTENT_TYPES.include?(file.content_type)
#           return {
#             valid: false,
#             error: "Invalid file type. Allowed types: #{ALLOWED_EXTENSIONS.join(', ')}"
#           }
#         end

#         # Check file extension for additional safety
#         original_filename = file.original_filename
#         if original_filename
#           extension = original_filename.split('.').last.downcase
#           unless ALLOWED_EXTENSIONS.include?(extension)
#             return {
#               valid: false,
#               error: "Invalid file extension. Allowed: #{ALLOWED_EXTENSIONS.join(', ')}"
#             }
#           end
#         end
#       else
#         return { valid: false, error: 'Invalid file format' }
#       end

#       { valid: true }
#     end

#     # Validate file size
#     # @param file [ActionDispatch::Http::UploadedFile] - The file to check
#     # @return [Hash] - Validation result
#     def validate_size(file)
#       return { valid: false, error: 'No file provided' } if file.blank?

#       file_size = file.tempfile.size
#       if file_size > MAX_FILE_SIZE
#         return {
#           valid: false,
#           error: "File size (#{(file_size / 1.megabyte).round(2)}MB) exceeds maximum of #{MAX_FILE_SIZE / 1.megabyte}MB"
#         }
#       end

#       { valid: true, size: file_size }
#     end

#     # Validate file type
#     # @param file [ActionDispatch::Http::UploadedFile] - The file to check
#     # @return [Hash] - Validation result
#     def validate_type(file)
#       return { valid: false, error: 'No file provided' } if file.blank?

#       unless ALLOWED_CONTENT_TYPES.include?(file.content_type)
#         return {
#           valid: false,
#           error: "Invalid file type: #{file.content_type}. Allowed: #{ALLOWED_CONTENT_TYPES.join(', ')}"
#         }
#       end

#       { valid: true, content_type: file.content_type }
#     end

#     # Get upload options with default transformations
#     # @param options [Hash] - Additional options
#     # @return [Hash] - Complete upload options
#     def build_upload_options(options = {})
#       default_options = {
#         folder: ENV['CLOUDINARY_UPLOAD_FOLDER'] || 'ecommerce_products',
#         resource_type: 'image',
#         overwrite: true,
#         invalidate: true
#       }

#       # Add default transformation if not provided
#       unless options[:transformation]
#         default_options[:transformation] = TRANSFORMATIONS[:main]
#       end

#       default_options.merge(options)
#     end

#     # Generate a signed URL for private content (optional)
#     # @param public_id [String] - The public ID of the image
#     # @param options [Hash] - URL options
#     # @return [String] - Signed URL
#     def signed_url(public_id, options = {})
#       return nil if public_id.blank?

#       Cloudinary::Utils.cloudinary_url(
#         public_id,
#         options.merge(sign_url: true)
#       )
#     end
#   end
# end


