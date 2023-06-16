# OCI Volume Backup Policy for multiples accounts with Terraform module
* This module simplifies creating and configuring of Volume Backup Policy across multiple accounts on OCI

* Is possible use this module with one account using the standard profile or multi account using multiple profiles setting in the modules.

## Actions necessary to use this module:

* Criate file provider.tf with the exemple code below:
```hcl
provider "oci" {
  alias   = "alias_profile_a"
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.ssh_private_key_path
  region           = var.region
}

provider "oci" {
  alias   = "alias_profile_b"
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.ssh_private_key_path
  region           = var.region
}
```


## Features enable of Subnet configurations for this module:

- Volume backup policy
- Volume group

## Usage exemples


### Create backup policy with volumes groups
* rule 1 make one backup once a day and keep for one week
* rule 2 make one backup once a week and keep for two weeks
* this policy will be applied for all volume IDs


```hcl
module "buckp_test" {
  source = "web-virtua-oci-multi-account-modules/backup/oci"

  name           = "tf-backup-test"
  compartment_id = var.compartment_id

  backup_schedules = [
    {
      backup_type = "INCREMENTAL"
      period      = "ONE_DAY"
      hour_of_day = 23
    },
    {
      backup_type       = "INCREMENTAL"
      period            = "ONE_WEEK"
      retention_seconds = 1209600
      hour_of_day       = 23
    }
  ]

  volume_groups = [
    {
      name                = "tf-backup-test"
      availability_domain = var.availability_domain
      volume_ids = [
        var.volume_1
      ]
    }
  ]

  providers = {
    oci = oci.alias_profile_a
  }
}
```


## Variables

| Name | Type | Default | Required | Description | Options |
|------|-------------|------|---------|:--------:|:--------|
| compartment_id | `string` | `-` | yes | Compartment ID | `-` |
| name | `string` | `-` | yes | Backup name | `-` |
| compartment_name | `string` | `-` | no | Compartment name | `-` |
| destination_region | `string` | `null` | no | The paired destination region for copying scheduled backups to. Example: us-ashburn-1 | `-` |
| use_tags_default | `bool` | `true` | no | If true will be use the tags default to resources | `*`false <br> `*`true |
| tags | `map(any)` | `{}` | no | Tags to backup | `-` |
| defined_tags | `map(any)` | `{}` | no | Defined tags to backup | `-` |
| backup_schedules | `list(object)` | `{}` | no | List with backup schedules | `-` |
| volume_groups | `list(object)` | `{}` | no | List with volume groups | `-` |

* Model of backup_schedules variable
```hcl
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
  default = [
    {
      backup_type = "INCREMENTAL"
      period      = "ONE_DAY"
      hour_of_day = 23
    }
  ]
}
```

* Model of volume_groups variable
```hcl
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
  default = [
    {
      name                = "tf-backup-name-test"
      availability_domain = data.oci_identity_availability_domain.ad1.name
      volume_ids = [
        "ocid1.bootvolume.oc1.sa-saopaulo-1.abtxeljrzjjmhbzjrzu2zrchg77d5imlvgqvf73j35a3g5cqwoa6uakcwjva"
      ]
    }
  ]
}
```


## Resources

| Name | Type |
|------|------|
| [oci_core_volume_backup_policy.create_volume_backup_policy](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_volume_backup_policy) | resource |
| [oci_core_volume_group.create_volume_groups](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_volume_group.html) | resource |

## Outputs

| Name | Description |
|------|-------------|
| `backup_policy` | Volume backup policy |
| `backup_policy_id` | Volume backup policy ID |
| `volume_groups` | Volume groups |
