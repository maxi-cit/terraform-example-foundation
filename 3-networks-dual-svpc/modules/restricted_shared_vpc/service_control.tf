/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  prefix            = "${var.environment_code}_shared_restricted"
  access_level_name = "alp_${local.prefix}_members_${random_id.random_access_level_suffix.hex}"
  perimeter_name    = "sp_${local.prefix}_default_perimeter_${random_id.random_access_level_suffix.hex}"
  bridge_name       = "spb_c_to_${local.prefix}_bridge_${random_id.random_access_level_suffix.hex}"
}

resource "random_id" "random_access_level_suffix" {
  byte_length = 2
}

module "access_level_members" {
  source  = "terraform-google-modules/vpc-service-controls/google//modules/access_level"
  version = "~> 4.0"

  description = "${local.prefix} Access Level"
  policy      = var.access_context_manager_policy_id
  name        = local.access_level_name
  members     = var.members
}

module "regular_service_perimeter" {
  source  = "terraform-google-modules/vpc-service-controls/google//modules/regular_service_perimeter"
  version = "~> 4.0"

  policy         = var.access_context_manager_policy_id
  perimeter_name = local.perimeter_name
  description    = "Default VPC Service Controls perimeter"
  resources      = [var.project_number]
  access_levels  = [module.access_level_members.name]

  restricted_services = var.restricted_services

  ingress_policies = var.ingress_policies
  egress_policies  = var.egress_policies
}
