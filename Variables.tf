variable "aws_region" {
    type = string
    description = "Region where the resource will be created in Akhil"
    default="eu-central-1"
}
variable "instance_type" {
    type = string
    description = "Type of the instance you want to create"
    default="t2.micro"
}
variable "key_pair" {
    type = string
    description = "Key Pair you want to attach to the instance"
    default="Terraform-Test"
}
