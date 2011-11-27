# Extending existing User model with new methods.
require File.expand_path("../../app/models/user_extension", __FILE__)
User.send :include, UserExtension
