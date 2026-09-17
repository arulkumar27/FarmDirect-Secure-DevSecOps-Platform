variable "name" {
    type=string
}

variable "vpc_id" {
    type=string
}

variable "vpc_cidr" {
    type=string
}

variable "region" {
    type=string
}

variable "subnet_ids" {
    type=list(string)
}

variable "route_table_ids" {
    type=list(string)
}

variable "create_endpoints" {
    type=bool
    default=false
}

variable "create_interface_endpoints" {
    type=bool
    default=false
}

variable "services" {
    type=list(string)
    default=["ecr.api","ecr.dkr","logs","sts","secretsmanager"]
}

variable "tags" {
    type=map(string)
    default={}
}
