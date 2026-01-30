# Plan: Restrict Product Creation/Editing for Non-Admin Users

## Information Gathered:
1. **ApplicationController** (`app/controllers/application_controller.rb`):
   - Has `current_user` and `logged_in?` helper methods
   - Already has `require_admin` method that redirects non-admins
   - Admin check: `current_user&.admin?` 

2. **ProductsController** (`app/controllers/products_controller.rb`):
   - Currently has NO authorization checks
   - Actions: index, show, new, edit, create, update, destroy
   - Uses `set_product` before_action for show, edit, update, destroy

3. **Routes** (`config/routes.rb`):
   - `resources :products` - accessible to all users
   - `namespace :admin do resources :products` - admin-only routes

4. **Views**:
   - `app/views/products/index.html.erb` has "New Product" link visible to all
   - Navigation already shows admin links only to admins

## Plan:
### 1. Controller-Level Protection (Primary Security)
   - Add `before_action :require_admin` to ProductsController for :new, :create, :edit, :update actions
   - This prevents direct URL access to these actions for non-admins

### 2. View-Level Protection (UI Enhancement)
   - Update `app/views/products/index.html.erb` to hide "New Product" link from non-admins
   - Optionally hide edit links on product show pages for non-admins

### 3. Redirect Location
   - Non-admins attempting to access restricted actions will be redirected to root_path with alert

## Files to Modify:
1. `app/controllers/products_controller.rb` - Add admin authorization
2. `app/views/products/index.html.erb` - Hide "New Product" link conditionally
3. `app/views/products/show.html.erb` - Hide edit link for non-admins

## Follow-up Steps:
- Test the changes by trying to access /products/new as a normal user
- Verify admin users can still access all product management features
- Check that flash messages display correctly

