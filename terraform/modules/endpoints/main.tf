resource "aws_vpc_endpoint" "s3" {
    count=var.create_endpoints?1:0
    vpc_id=var.vpc_id
    service_name="com.amazonaws.${var.region}.s3"
    vpc_endpoint_type="Gateway"
    route_table_ids=var.route_table_ids
    tags=var.tags
}

resource "aws_security_group" "vpce" {
    count=var.create_interface_endpoints?1:0
    name="${var.name}-vpce-sg"
    vpc_id=var.vpc_id
    ingress {
        from_port=443
        to_port=443
        protocol="tcp"
        cidr_blocks=[var.vpc_cidr]
    }

    egress {
        from_port=0
        to_port=0
        protocol="-1"
        cidr_blocks=["0.0.0.0/0"]
    }
        tags=var.tags
}

resource "aws_vpc_endpoint" "interface" {
    for_each=var.create_interface_endpoints?toset(var.services):[]
    vpc_id=var.vpc_id
    service_name="com.amazonaws.${var.region}.${each.value}"
    vpc_endpoint_type="Interface"
    subnet_ids=var.subnet_ids
    security_group_ids=[aws_security_group.vpce[0].id]
    private_dns_enabled=true
    tags=var.tags
}
