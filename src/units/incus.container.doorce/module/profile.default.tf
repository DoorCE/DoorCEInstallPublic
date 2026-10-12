
# Is default profile needed?
# It is created by default by incus, and we do not want to modify it,
# so maybe we can just use it without importing it?
#
# import {
#   to = incus_profile.default
#   id = "default"
# }
#
# resource "incus_profile" "default" {
#   name        = "default"
#   description = "Default Incus profile"
#   config = {}
#     lifecycle {
#         prevent_destroy = true
#     }
# }