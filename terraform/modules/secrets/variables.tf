variable "name" {
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

variable "jwt_secret" {
    type=string
    sensitive=true
}

variable "tags" {
    type=map(string)
    default={}
}
