#---------------------------------------
# Creates all IAM Resources for this demo
#---------------------------------------

# Create iam role that will be attached to ec2 instances
# This uses a data block to import ec2 assume policy
resource "aws_iam_role" "demo_instances_role" {
  assume_role_policy = data.template_file.ec2_assume_role.rendered
  name               = "idea11-ci-demo-ec2-role"

  tags = {
    Name      = "idea11-ci-demo-ec2-role"
    Terraform = "True"
  }
}

# Create instance profile name for ASG setup
resource "aws_iam_instance_profile" "ec2_demo_instance_profile" {
  name = "idea11-ci-demo-instance-profile"
  role = aws_iam_role.demo_instances_role.name
}

#-------------------------------------------
# Attaches EC2 FULL ACCESS PERMISSIONS to IAM Role
# DO NOT EVER DO THIS IN PRODUCTION I WAS BEING LAZY
#--------------------------------------------
resource "aws_iam_role_policy_attachment" "ec2_fullaccess_attach" {
  role       = aws_iam_role.demo_instances_role.name
  policy_arn = data.aws_iam_policy.Ec2FullAccessPolicy.arn
}

#-------------------------------------------
# Attaches EC2 SSM policy to IAM Role
# TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP
# :TODO REMOVE THIS
#--------------------------------------------
resource "aws_iam_role_policy_attachment" "ec2_ssm_attach" {
  role       = aws_iam_role.demo_instances_role.name
  policy_arn = data.aws_iam_policy.Ec2SSMCorePolicy.arn
}
#############################################################

# Create iam role that will be attached to codepipeline
# This uses a data block to import codepipeline assume policy
resource "aws_iam_role" "demo_codepipeline_role" {
  assume_role_policy = data.template_file.codepipeline_assume_role.rendered
  name               = "idea11-ci-demo-codepipeline-role"

  tags = {
    Name      = "idea11-ci-demo-codepipeline-role"
    Terraform = "True"
  }
}

# Create iam role that will be attached to codebuild
# This uses a data block to import codebuild assume policy
resource "aws_iam_role" "demo_codebuild_role" {
  assume_role_policy = data.template_file.codebuild_assume_role.rendered
  name               = "idea11-ci-demo-codebuild-role"

  tags = {
    Name      = "idea11-ci-demo-codebuild-role"
    Terraform = "True"
  }
}

resource "aws_iam_policy" "codestar_connections_policy" {
  policy = data.template_file.codestarconnections_policy.rendered
  name   = "AllowAccessTo-CodestarConnections"
}

#-------------------------------------------
# Attaches CodePipeline FULL ACCESS PERMISSIONS to IAM Role
# DO NOT EVER DO THIS IN PRODUCTION I WAS BEING LAZY
#--------------------------------------------
resource "aws_iam_role_policy_attachment" "codepipeline_cp_fullaccess_attach" {
  role       = aws_iam_role.demo_codepipeline_role.name
  policy_arn = data.aws_iam_policy.CodePipelineFullAccessPolicy.arn
}

#-------------------------------------------
# Attaches S3 FULL ACCESS PERMISSIONS to IAM Role
# DO NOT EVER DO THIS IN PRODUCTION I WAS BEING LAZY
#--------------------------------------------
resource "aws_iam_role_policy_attachment" "codepipeline_s3_fullaccess_attach" {
  policy_arn = data.aws_iam_policy.S3FullAccessPolicy.arn
  role       = aws_iam_role.demo_codepipeline_role.name
}

#-------------------------------------------
# Attaches Codestar FULL ACCESS PERMISSIONS to IAM Role
# DO NOT EVER DO THIS IN PRODUCTION I WAS BEING LAZY
#--------------------------------------------
resource "aws_iam_role_policy_attachment" "codepipeline_codestar_fullaccess_attach" {
  policy_arn = data.aws_iam_policy.CodeStarFullAccessPolicy.arn
  role       = aws_iam_role.demo_codepipeline_role.name
}

# Attach codestar connections policy to codepipeline role
resource "aws_iam_role_policy_attachment" "codepipelin_codestar_connect_attach" {
  policy_arn = aws_iam_policy.codestar_connections_policy.arn
  role       = aws_iam_role.demo_codepipeline_role.name
}

#-------------------------------------------
# Attaches S3 FULL ACCESS PERMISSIONS to IAM Role
# DO NOT EVER DO THIS IN PRODUCTION I WAS BEING LAZY
#--------------------------------------------
resource "aws_iam_role_policy_attachment" "codebuild_s3_fullaccess_attach" {
  policy_arn = data.aws_iam_policy.S3FullAccessPolicy.arn
  role       = aws_iam_role.demo_codebuild_role.name
}