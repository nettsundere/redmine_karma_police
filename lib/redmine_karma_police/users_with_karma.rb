# Extending existing User model with new methods.
require File.expand_path("../../../app/models/user_extension", __FILE__)
if not User.included_modules.include? UserExtension
  User.send :include, UserExtension
end
