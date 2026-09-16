output "s3_endpoint_id" {
  value = try(aws_vpc_endpoint.s3[0].id, null)
}

output "interface_endpoint_ids" {
  value = {
    for service, endpoint in aws_vpc_endpoint.interface : service => endpoint.id
  }
}