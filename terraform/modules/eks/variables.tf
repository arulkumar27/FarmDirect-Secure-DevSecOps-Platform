variable "cluster_name" {
    type=string
}

variable "environment" {
    type=string
}

variable "kubernetes_version" {
    type=string
    default="1.33"
}

variable "cluster_role_arn" {
    type=string
}

variable "node_role_arn" {
    type=string
}

variable "subnet_ids" {
    type=list(string)
}

variable "cluster_security_group_id" {
    type=string
}

variable "node_security_group_id" {
    type=string
}

variable "instance_type" {
    type=string
    default="t3.small"
}

variable "desired_nodes" {
    type=number
    default=2
}
variable "min_nodes" {
    type=number
    default=2
}

variable "max_nodes" {
    type=number
    default=2
}
variable "cluster_log_types" {
    type=list(string)
    default=["api","audit","authenticator"]
}

variable "tags" {
    type=map(string)
    default={}
}

