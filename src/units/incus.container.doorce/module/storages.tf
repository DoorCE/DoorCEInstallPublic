resource "incus_storage_pool" "members-local-dir" {
  for_each = var.members
  name        = "local-dir"
  driver      = "dir"
  target      = each.key
}


resource "incus_storage_pool" "local_dir" {
  depends_on = [
    incus_storage_pool.members-local-dir,
  ]
  name        = "local-dir"
  driver      = "dir"
  config = {
    # "source" = "/var/lib/incus/storage-pools/local-dir" # Optional - default is /var/lib/incus/storage-pools/local_dir
  }
}
