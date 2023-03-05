variable "sg-group" {
  description = "Security group default"
  type        = string
  default     = "any-sg"
}

variable "subnets" {
  description = "Subnets to use in Subnet Group created to DMS"
  type        = list(string)
}

variable "database-name" {
  description = "Source db name"
  type        = string
}

variable "database-password" {
  description = "Source db password"
  type        = string
}

variable "database-port" {
  description = "Source db port"
  type        = string
}

variable "database-user" {
  description = "Source db user"
  type        = string
}

variable "database-server" {
  description = "Source db server"
  type        = string
}

variable "bucket-name" {
  description = "Target S3 bucket name"
  type        = string
}

variable "target-endpoint-role" {
  description = "ARN Role with S3 read and write permissions"
  type        = string
}