variable "domain_name" {
    type=string
    default=""
    }

variable "zone_id" {
    type=string
    default=""
    }

variable "create_certificate" {
    type=bool
    default=false
    }

variable "tags" {
    type=map(string)
    default={}
    }