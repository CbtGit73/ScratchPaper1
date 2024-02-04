variable "objects" {
  type = map(string)
}

variable "domain" {
  description = "List of Domaain Names"
  type        = list(string)
}
