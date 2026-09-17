variable "name" {
    type=string
}
    
variable "subnet_ids" {
    type=list(string)
}

variable "security_group_id" {
    type=string
}

variable "database_name" {
    type=string
}

variable "database_username" {
    type=string
}

variable "database_password" {
    type=string
    sensitive=true
}

variable "engine_version" {
    type=string
    default="16"
}

variable "instance_class" {
    type=string
    default="db.t3.micro"
}

variable "storage" {
    type=number
    default=20
}

variable "tags" {
    type=map(string)
    default={}
}
