output "backup_policy" {
  description = "Volume backup policy"
  value       = oci_core_volume_backup_policy.create_volume_backup_policy
}

output "backup_policy_id" {
  description = "Volume backup policy ID"
  value       = oci_core_volume_backup_policy.create_volume_backup_policy.id
}

output "volume_groups" {
  description = "Volume groups"
  value       = try(oci_core_volume_group.create_volume_groups, null)
}
