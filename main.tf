locals {
  tags_policy = {
    "tf-name"        = var.name
    "tf-type"        = "backup-policy"
    "tf-compartment" = var.compartment_name
  }
}

resource "oci_core_volume_backup_policy" "create_volume_backup_policy" {
  compartment_id     = var.compartment_id
  display_name       = var.name
  defined_tags       = var.defined_tags
  freeform_tags      = merge(var.tags, var.use_tags_default ? local.tags_policy : {})
  destination_region = var.destination_region

  dynamic "schedules" {
    for_each = var.backup_schedules != null ? { for index, backup_schedule in var.backup_schedules : index => backup_schedule } : {}

    content {
      backup_type       = schedules.value.backup_type
      period            = schedules.value.period
      retention_seconds = schedules.value.retention_seconds
      hour_of_day       = schedules.value.hour_of_day
      time_zone         = schedules.value.time_zone
      day_of_month      = schedules.value.day_of_month
      day_of_week       = schedules.value.day_of_week
      month             = schedules.value.month
      offset_seconds    = schedules.value.offset_seconds
      offset_type       = schedules.value.offset_type
    }
  }
}

resource "oci_core_volume_group" "create_volume_groups" {
  for_each = { for index, volume_group in var.volume_groups : index => volume_group }

  availability_domain = each.value.availability_domain
  compartment_id      = each.value.compartment_id != null ? each.value.compartment_id : var.compartment_id
  display_name        = each.value.name != null ? each.value.name : "${var.name}-volume-group"
  backup_policy_id    = each.value.backup_policy_id != null ? each.value.backup_policy_id : oci_core_volume_backup_policy.create_volume_backup_policy.id
  defined_tags        = each.value.defined_tags
  freeform_tags       = each.value.freeform_tags

  source_details {
    type                    = each.value.type
    volume_ids              = each.value.volume_ids
    volume_group_backup_id  = each.value.volume_group_backup_id
    volume_group_id         = each.value.volume_group_id
    volume_group_replica_id = each.value.volume_group_replica_id
  }

  dynamic "volume_group_replicas" {
    for_each = each.value.volume_group_replicas != null ? [1] : []

    content {
      availability_domain = each.value.volume_group_replicas.availability_domain
      display_name        = each.value.volume_group_replicas.display_name
    }
  }
}
