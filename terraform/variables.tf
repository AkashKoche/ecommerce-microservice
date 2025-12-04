variable "db_password" {
  description   = "The password for the database. this should be kept secret"
  type          = string
  sensitive     = true
}

variable "private_subnet_cidrs" {
  description = "A list of CIDR blocks for the private subnets."
  type        = list(string)
  default = ["10.0.10.0/24", "10.0.11.0/24"]
}
