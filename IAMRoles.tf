// I created this datasource for attaching an IAM role for SSM agent
data "aws_iam_role" "Role" {
  name = "AmazonSSMRoleForInstancesQuickSetup"
}
