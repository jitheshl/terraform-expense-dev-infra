variable "project_name"{
    default = "expense"
}

variable "environment"{
    default = "dev"
}

variable "common_tags"{
    default = {
    Terraform = true
    environment = "dev"
    project_name = "expense"
    }
}