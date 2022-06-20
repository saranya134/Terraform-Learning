// I created this data block for getting all the avaliable AZ 
data "aws_availability_zones" "Avaliable-AZ" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}
