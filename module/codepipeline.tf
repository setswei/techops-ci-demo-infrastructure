# Creates a codestar connection to github. as direct connections to github are deprecated
# https://docs.aws.amazon.com/codepipeline/latest/userguide/update-github-action-connections.html and
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codestarconnections_connection
resource "aws_codestarconnections_connection" "codestar_github" {
  name          = "techops-demo-github-connection"
  provider_type = "GitHub"
}

# Create AWS CodePipeline to deploy web application
resource "aws_codepipeline" "pipeline" {
  name     = "techops-ci-demo-pipline"
  role_arn = aws_iam_role.demo_codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codebuild_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Sources"
    action {
      category         = "Source"
      name             = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_object"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.codestar_github.arn
        FullRepositoryId = "${var.repo_owner}/${var.repo_name}"
        BranchName       = var.repo_branch
      }
    }
  }

  stage {
    name = "Build"
    action {
      category         = "Build"
      name             = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_object"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.build_project.name
      }
    }
  }
}

resource "aws_codebuild_project" "build_project" {
  name         = "techops-ci-demo-build-project"
  service_role = aws_iam_role.demo_codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }
  }

  cache {
    type     = "S3"
    location = "${aws_s3_bucket.codebuild_bucket.bucket}/cache"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}