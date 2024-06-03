# Splitting and joining, and then compacting a list to get a normalised list
locals {
  name_list = compact(concat(keys(local.parameter_write), keys(local.parameter_write_ignore_values), local.parameter_read))

  read_value_list = [for p in data.aws_ssm_parameter.read.* : coalesce(p.value, p.insecure_value)]

  value_list = compact(
    concat(
      [for p in aws_ssm_parameter.default : coalesce(p.value, p.insecure_value)], [for p in aws_ssm_parameter.ignore_value_changes : coalesce(p.value, p.insecure_value)], local.read_value_list
    )
  )

  arn_list = compact(
    concat(
      [for p in aws_ssm_parameter.default : p.arn], [for p in aws_ssm_parameter.ignore_value_changes : p.arn], data.aws_ssm_parameter.read.*.arn
    )
  )
}

output "names" {
  # Names are not sensitive
  value       = local.name_list
  description = "A list of all of the parameter names"
}

output "values" {
  description = "A list of all of the parameter values"
  value       = local.value_list
  sensitive   = true
}

output "map" {
  description = "A map of the names and values created"
  value       = zipmap(local.name_list, local.value_list)
  sensitive   = true
}

output "arn_map" {
  description = "A map of the names and ARNs created"
  value       = zipmap(local.name_list, local.arn_list)
}
