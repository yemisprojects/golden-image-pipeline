################################################################################
# SLACK FOR PIPELINE STATUS
################################################################################
module "slack_notification" {
  source = "../modules/pipeline-chatbot-slack"

  configuration_name = "cpipeline-status"
  slack_channel_id   = var.slack_channel_id
  slack_workspace_id = var.slack_workspace_id

  notification_rules_config = {
    ami_cp = {
      detail_type            = "BASIC"
      notification_rule_name = "ami-pipeline-slack"
      pipeline_arn           = module.golden_ami_pipeline.codepipeline_arn
      event_type_ids = [
        "codepipeline-pipeline-pipeline-execution-started",
        "codepipeline-pipeline-pipeline-execution-failed",
        "codepipeline-pipeline-pipeline-execution-canceled",
        "codepipeline-pipeline-pipeline-execution-succeeded",
        "codepipeline-pipeline-manual-approval-needed",
        "codepipeline-pipeline-manual-approval-succeeded",
        "codepipeline-pipeline-manual-approval-failed"
      ]
    }

  }
}
