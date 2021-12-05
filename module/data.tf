# This data block retrieves the aws account id
data "aws_caller_identity" "current" {}

# references the assume role policy in templates directory
data "template_file" "ec2_assume_role" {
  template = file("${path.module}/templates/iam_assume_role_ec2_policy.json")
}

# references the assume role policy in templates directory
data "template_file" "codepipeline_assume_role" {
  template = file("${path.module}/templates/iam_assume_role_codepipeline_policy.json")
}

# references the assume role policy in templates directory
data "template_file" "codebuild_assume_role" {
  template = file("${path.module}/templates/iam_assume_role_codebuild_policy.json")
}

# references the assume role policy in templates directory
data "template_file" "codestarconnections_policy" {
  template = file("${path.module}/templates/iam_policy_perms_codestarconnections.json")
}

#--------------------------------------------------
# Imports the Managed EC2FullAccessPolicy
# This is me being lazy. you should never do this
#--------------------------------------------------
data "aws_iam_policy" "Ec2FullAccessPolicy" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

#--------------------------------------------------
# Imports the Managed EC2FullAccessPolicy
# This is me being lazy. you should never do this
#--------------------------------------------------
data "aws_iam_policy" "CodePipelineFullAccessPolicy" {
  arn = "arn:aws:iam::aws:policy/AWSCodePipelineFullAccess"
}

#--------------------------------------------------
# Imports the Managed CodeBuildFullAccessPolicy
# This is me being lazy. you should never do this
#--------------------------------------------------
data "aws_iam_policy" "CodeBuildFullAccessPolicy" {
  arn = "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"
}

#--------------------------------------------------
# Imports the Managed S3FullAccessPolicy
# This is me being lazy. you should never do this
#--------------------------------------------------
data "aws_iam_policy" "S3FullAccessPolicy" {
  arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

#--------------------------------------------------
# Imports the Managed CodeStarFullAccess
# This is me being lazy. you should never do this
#--------------------------------------------------
data "aws_iam_policy" "CodeStarFullAccessPolicy" {
  arn = "arn:aws:iam::aws:policy/AWSCodeStarFullAccess"
}

# Get the latest amazon linux ami from public parameter store
data "aws_ssm_parameter" "ssm_amazon_linux_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn-ami-hvm-x86_64-ebs"
}

#-------------------------------------------
# TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP
# :TODO REMOVE THIS
#--------------------------------------------
data "aws_iam_policy" "Ec2SSMCorePolicy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}
#############################################