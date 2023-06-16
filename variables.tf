variable "compartment_id" {
  description = "Compartment ID"
  type        = string
}

variable "name" {
  description = "Subnet name"
  type        = string
}

variable "compartment_name" {
  description = "Compartment name"
  type        = string
  default     = null
}

variable "destination_region" {
  description = "The paired destination region for copying scheduled backups to. Example: us-ashburn-1"
  type        = string
  default     = null
}

variable "use_tags_default" {
  description = "If true will be use the tags default to resources"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to VCN"
  type        = map(any)
  default     = {}
}

variable "defined_tags" {
  description = "Defined tags to VCN"
  type        = map(any)
  default     = null
}

variable "backup_schedules" {
  description = "List with backup schedules"
  type = list(object({
    period            = optional(string)
    hour_of_day       = optional(number, 23)
    retention_seconds = optional(number, 604800)
    backup_type       = optional(string, "INCREMENTAL")
    time_zone         = optional(string, "REGIONAL_DATA_CENTER_TIME")
    day_of_month      = optional(number)
    day_of_week       = optional(string)
    month             = optional(string)
    offset_seconds    = optional(number)
    offset_type       = optional(string)
  }))
  default = []
}

variable "volume_groups" {
  description = "List with volume groups"
  type = list(object({
    availability_domain     = string
    volume_ids              = list(string)
    compartment_id          = optional(string)
    type                    = optional(string, "volumeIds")
    backup_policy_id        = optional(string)
    name                    = optional(string)
    volume_group_backup_id  = optional(string)
    volume_group_id         = optional(string)
    volume_group_replica_id = optional(string)
    defined_tags            = optional(any)
    freeform_tags           = optional(any)
    volume_group_replicas = optional(object({
      availability_domain = string
      display_name        = optional(string)
    }))
  }))
  default = []
}
