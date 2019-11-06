/*provider "aws" {
  profile = "default"
  region = "eu-west-3"
}*/

#==============================Creating EC2 Instance==========================================

resource "aws_launch_configuration" "ECS-LaunchConfig" {
  image_id = "ami-084782c5b95d70e09"
  instance_type = "m5.large"
  //  iam_instance_profile = "arn:aws:iam::639716861848:role/aws-elasticbeanstalk-ec2-role"
  iam_instance_profile = "${aws_iam_instance_profile.Instance-to-ECSCluster.name}"
  //    name_prefix = "${aws_ecs_cluster.docker-QA-cl-rep.name}"
  associate_public_ip_address = true
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_type = "gp2"
    volume_size = "50"
  }
  vpc_classic_link_id = "${aws_vpc.stage_qa.id}"
  vpc_classic_link_security_groups = [
    "${aws_security_group.ECSCluster.id}"]
  name = "ECSCluster-launch-configuration"
  user_data = <<EOF
          #!/bin/bash
          echo ECS_CLUSTER=${aws_ecs_cluster.docker-QA-cl-rep.name} >> /etc/ecs/ecs.config;echo ECS_BACKEND_HOST= >> /etc/ecs/ecs.config;
          Content-Type: multipart/mixed; boundary="==BOUNDARY=="
          MIME-Version: 1.0

          --==BOUNDARY==
          Content-Type: text/cloud-boothook; charset="us-ascii"
  EOF

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "ECSAutoscaling" {
  launch_configuration = "${aws_launch_configuration.ECS-LaunchConfig.name}"
  vpc_zone_identifier = [
    "${aws_subnet.PrivateSubnetA.id}",
    "${aws_subnet.PrivateSubnetB.id}",
    "${aws_subnet.PrivateSubnetC.id}"]
  min_size = 1
  max_size = 6
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy" "EC2Instance-to-ECSCLuster-role-policy" {
  role = "${aws_iam_role.EC2Instance-to-ECSCLuster-role.id}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ECSAccess",
            "Effect": "Allow",
            "Action": [
                "ecs:Poll",
                "ecs:StartTask",
                "ecs:StopTask",
                "ecs:DiscoverPollEndpoint",
                "ecs:StartTelemetrySession",
                "ecs:RegisterContainerInstance",
                "ecs:DeregisterContainerInstance",
                "ecs:DescribeContainerInstances",
                "ecs:Submit*",
                "ecs:DescribeTasks"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "Instance-to-ECSCluster" {
  name = "Instance-to-ECSCluster"
  role = "${aws_iam_role.EC2Instance-to-ECSCLuster-role.name}"
}

resource "aws_iam_role" "EC2Instance-to-ECSCLuster-role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

#=================================Creating CLuster============================================

resource "aws_ecs_cluster" "docker-QA-cl-rep" {
  name = "docker-qa-cl-replica"
}

#=================================Creating Task Definitions===================================

resource "aws_ecs_task_definition" "billing-docker-qa" {
  container_definitions = "${file("TaskDefinitions/billing-docker-qa.json")}"
  family = "billing-docker-qa"

  volume {
    name = "billing-docker-qa"
    host_path = "/ecs/billing-docker-qa"
  }
  execution_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  task_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  requires_compatibilities = [
    "EC2"]
  network_mode = "bridge"
}

resource "aws_ecs_task_definition" "campaigns-docker-qa" {
  container_definitions = "${file("TaskDefinitions/campaigns-docker-qa.json")}"
  family = "campaigns-docker-qa"

  volume {
    name = "campaigns-docker-qa"
    host_path = "/ecs/campaigns-docker-qa"
  }
  execution_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  task_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  requires_compatibilities = [
    "EC2"]
  network_mode = "bridge"
}

resource "aws_ecs_task_definition" "cashback-docker-qa" {
  container_definitions = "${file("TaskDefinitions/cashback-docker-qa.json")}"
  family = "cashback-docker-qa"

  volume {
    name = "cashback-docker-qa"
    host_path = "/ecs/cashback-docker-qa"
  }
  execution_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  task_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  requires_compatibilities = [
    "EC2"]
  network_mode = "bridge"
}

resource "aws_ecs_task_definition" "earlybird-docker-qa" {
  container_definitions = "${file("TaskDefinitions/earlybird-docker-qa.json")}"
  family = "earlybird-docker-qa"

  volume {
    name = "earlybird-docker-qa"
    host_path = "/ecs/earlybird-docker-qa"
  }
  execution_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  task_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  requires_compatibilities = [
    "EC2"]
  network_mode = "bridge"
}

resource "aws_ecs_task_definition" "googleplaces-docker-qa" {
  container_definitions = "${file("TaskDefinitions/googleplaces-docker-qa.json")}"
  family = "googleplaces-docker-qa"

  volume {
    name = "googleplaces-docker-qa"
    host_path = "/ecs/googleplaces-docker-qa"
  }
  execution_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  task_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  requires_compatibilities = [
    "EC2"]
  network_mode = "bridge"
}

resource "aws_ecs_task_definition" "kyc-docker-qa" {
  container_definitions = "${file("TaskDefinitions/kyc-docker-qa.json")}"
  family = "kyc-docker-qa"

  volume {
    name = "kyc-docker-qa"
    host_path = "/ecs/kyc-docker-qa"
  }
  execution_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  task_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  requires_compatibilities = [
    "EC2"]
  network_mode = "bridge"
}

resource "aws_ecs_task_definition" "mailer-docker-qa" {
  container_definitions = "${file("TaskDefinitions/mailer-docker-qa.json")}"
  family = "mailer-docker-qa"

  volume {
    name = "mailer-docker-qa"
    host_path = "/ecs/mailer-docker-qa"
  }
  execution_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  task_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  requires_compatibilities = [
    "EC2"]
  network_mode = "bridge"
}

resource "aws_ecs_task_definition" "messaging-docker-qa" {
  container_definitions = "${file("TaskDefinitions/messaging-docker-qa.json")}"
  family = "messaging-docker-qa"

  volume {
    name = "messaging-docker-qa"
    host_path = "/ecs/messaging-docker-qa"
  }
  execution_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  task_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  requires_compatibilities = [
    "EC2"]
  network_mode = "bridge"
}

resource "aws_ecs_task_definition" "moleculer-user-management-docker-qa" {
  container_definitions = "${file("TaskDefinitions/moleculer-user-management-docker-qa.json")}"
  family = "moleculer-user-management-docker-qa"

  volume {
    name = "moleculer-user-management-docker-qa"
    host_path = "/ecs/moleculer-user-management-docker-qa"
  }
  execution_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  task_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  requires_compatibilities = [
    "EC2"]
  network_mode = "bridge"
}

resource "aws_ecs_task_definition" "notification-docker-qa" {
  container_definitions = "${file("TaskDefinitions/notification-docker-qa.json")}"
  family = "notification-docker-qa"

  volume {
    name = "notification-docker-qa"
    host_path = "/ecs/notification-docker-qa"
  }
  execution_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  task_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  requires_compatibilities = [
    "EC2"]
  network_mode = "bridge"
}

resource "aws_ecs_task_definition" "paywithcc-docker-qa" {
  container_definitions = "${file("TaskDefinitions/paywithcc-docker-qa.json")}"
  family = "paywithcc-docker-qa"

  volume {
    name = "paywithcc-docker-qa"
    host_path = "/ecs/paywithcc-docker-qa"
  }
  execution_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  task_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  requires_compatibilities = [
    "EC2"]
  network_mode = "bridge"
}

resource "aws_ecs_task_definition" "txreports-docker-qa" {
  container_definitions = "${file("TaskDefinitions/txreports-docker-qa.json")}"
  family = "txreports-docker-qa"

  volume {
    name = "txreports-docker-qa"
    host_path = "/ecs/txreports-docker-qa"
  }
  execution_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  task_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  requires_compatibilities = [
    "EC2"]
  network_mode = "bridge"
}

resource "aws_ecs_task_definition" "ratiomanager-docker-qa" {
  container_definitions = "${file("TaskDefinitions/ratiomanager-docker-qa.json")}"
  family = "ratiomanager-docker-qa"

  volume {
    name = "ratiomanager-docker-qa"
    host_path = "/ecs/ratiomanager-docker-qa"
  }
  execution_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  task_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  requires_compatibilities = [
    "EC2"]
  network_mode = "bridge"
}

resource "aws_ecs_task_definition" "referral-docker-qa" {
  container_definitions = "${file("TaskDefinitions/referral-docker-qa.json")}"
  family = "referral-docker-qa"

  volume {
    name = "referral-docker-qa"
    host_path = "/ecs/referral-docker-qa"
  }
  execution_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  task_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  requires_compatibilities = [
    "EC2"]
  network_mode = "bridge"
}

resource "aws_ecs_task_definition" "scheduler-docker-qa" {
  container_definitions = "${file("TaskDefinitions/scheduler-docker-qa.json")}"
  family = "scheduler-docker-qa"

  volume {
    name = "scheduler-docker-qa"
    host_path = "/ecs/scheduler-docker-qa"
  }
  execution_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  task_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  requires_compatibilities = [
    "EC2"]
  network_mode = "bridge"
}

resource "aws_ecs_task_definition" "rewards-docker-qa" {
  container_definitions = "${file("TaskDefinitions/rewards-docker-qa.json")}"
  family = "rewards-docker-qa"

  volume {
    name = "rewards-docker-qa"
    host_path = "/ecs/rewards-docker-qa"
  }
  execution_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  task_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  requires_compatibilities = [
    "EC2"]
  network_mode = "bridge"
}

resource "aws_ecs_task_definition" "sms-docker-qa" {
  container_definitions = "${file("TaskDefinitions/sms-docker-qa.json")}"
  family = "sms-docker-qa"

  volume {
    name = "sms-docker-qa"
    host_path = "/ecs/sms-docker-qa"
  }
  execution_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  task_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  requires_compatibilities = [
    "EC2"]
  network_mode = "bridge"
}

resource "aws_ecs_task_definition" "withdrawal-docker-qa" {
  container_definitions = "${file("TaskDefinitions/withdrawal-docker-qa.json")}"
  family = "withdrawal-docker-qa"

  volume {
    name = "withdrawal-docker-qa"
    host_path = "/ecs/withdrawal-docker-qa"
  }
  execution_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  task_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  requires_compatibilities = [
    "EC2"]
  network_mode = "bridge"
}

resource "aws_ecs_task_definition" "user-management-docker-qa" {
  container_definitions = "${file("TaskDefinitions/user-management-docker-qa.json")}"
  family = "user-management-docker-qa"

  volume {
    name = "user-management-docker-qa"
    host_path = "/ecs/user-management-docker-qa"
  }
  execution_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  task_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  requires_compatibilities = [
    "EC2"]
  network_mode = "bridge"
}

resource "aws_ecs_task_definition" "community-docker-qa" {
  container_definitions = "${file("TaskDefinitions/community-docker-qa.json")}"
  family = "community-docker-qa"

  volume {
    name = "community-docker-qa"
    host_path = "/ecs/community-docker-qa"
  }
  execution_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  task_role_arn = "arn:aws:iam::639716861848:role/AmazonElasticContainerServiceTaskRole"
  requires_compatibilities = [
    "EC2"]
  network_mode = "bridge"
}

#==================================Creating services======================================

resource "aws_ecs_service" "billing" {
  name = "billing"
  task_definition = "${aws_ecs_task_definition.billing-docker-qa.arn}"
  cluster = "${aws_ecs_cluster.docker-QA-cl-rep.id}"
  desired_count = 1
}

resource "aws_appautoscaling_target" "ecs-scaling-billing" {
  max_capacity = 2
  min_capacity = 1
  resource_id = "service/${aws_ecs_cluster.docker-QA-cl-rep.name}/${aws_ecs_service.billing.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"
}

resource "aws_ecs_service" "campaigns" {
  name = "campaigns"
  task_definition = "${aws_ecs_task_definition.campaigns-docker-qa.arn}"
  cluster = "${aws_ecs_cluster.docker-QA-cl-rep.id}"
  desired_count = 1
}

resource "aws_ecs_service" "cashback" {
  name = "cashback"
  task_definition = "${aws_ecs_task_definition.cashback-docker-qa.arn}"
  cluster = "${aws_ecs_cluster.docker-QA-cl-rep.id}"
  desired_count = 1
}

resource "aws_ecs_service" "earlybird" {
  name = "earlybird"
  task_definition = "${aws_ecs_task_definition.earlybird-docker-qa.arn}"
  cluster = "${aws_ecs_cluster.docker-QA-cl-rep.id}"
  desired_count = 1
}

resource "aws_ecs_service" "googleplaces" {
  name = "googleplaces"
  task_definition = "${aws_ecs_task_definition.googleplaces-docker-qa.arn}"
  cluster = "${aws_ecs_cluster.docker-QA-cl-rep.id}"
  desired_count = 1
}

resource "aws_ecs_service" "kyc" {
  name = "kyc"
  task_definition = "${aws_ecs_task_definition.kyc-docker-qa.arn}"
  cluster = "${aws_ecs_cluster.docker-QA-cl-rep.id}"
  desired_count = 1
}

resource "aws_ecs_service" "mailer-moleculer" {
  name = "mailer-moleculer"
  task_definition = "${aws_ecs_task_definition.mailer-docker-qa.arn}"
  cluster = "${aws_ecs_cluster.docker-QA-cl-rep.id}"
  desired_count = 2
}

resource "aws_ecs_service" "messaging" {
  name = "messaging"
  task_definition = "${aws_ecs_task_definition.messaging-docker-qa.arn}"
  cluster = "${aws_ecs_cluster.docker-QA-cl-rep.id}"
  desired_count = 1
}

resource "aws_ecs_service" "moleculer-user-management" {
  name = "moleculer-user-management"
  task_definition = "${aws_ecs_task_definition.moleculer-user-management-docker-qa.arn}"
  cluster = "${aws_ecs_cluster.docker-QA-cl-rep.id}"
  desired_count = 2
}

resource "aws_ecs_service" "notifier" {
  name = "notifier"
  task_definition = "${aws_ecs_task_definition.notification-docker-qa.arn}"
  cluster = "${aws_ecs_cluster.docker-QA-cl-rep.id}"
  desired_count = 1
}

resource "aws_ecs_service" "paywithcc" {
  name = "paywithcc"
  task_definition = "${aws_ecs_task_definition.paywithcc-docker-qa.arn}"
  cluster = "${aws_ecs_cluster.docker-QA-cl-rep.id}"
  desired_count = 1
}

resource "aws_ecs_service" "txreports" {
  name = "txreports"
  task_definition = "${aws_ecs_task_definition.txreports-docker-qa.arn}"
  cluster = "${aws_ecs_cluster.docker-QA-cl-rep.id}"
  desired_count = 1
}

resource "aws_ecs_service" "ratiomanager" {
  name = "ratiomanager"
  task_definition = "${aws_ecs_task_definition.ratiomanager-docker-qa.arn}"
  cluster = "${aws_ecs_cluster.docker-QA-cl-rep.id}"
  desired_count = 1
}

resource "aws_ecs_service" "referral" {
  name = "referral"
  task_definition = "${aws_ecs_task_definition.referral-docker-qa.arn}"
  cluster = "${aws_ecs_cluster.docker-QA-cl-rep.id}"
  desired_count = 1
}

resource "aws_ecs_service" "scheduler" {
  name = "scheduler"
  task_definition = "${aws_ecs_task_definition.scheduler-docker-qa.arn}"
  cluster = "${aws_ecs_cluster.docker-QA-cl-rep.id}"
  desired_count = 1
}

resource "aws_ecs_service" "rewards" {
  name = "rewards"
  task_definition = "${aws_ecs_task_definition.rewards-docker-qa.arn}"
  cluster = "${aws_ecs_cluster.docker-QA-cl-rep.id}"
  desired_count = 1
}

resource "aws_ecs_service" "sms" {
  name = "sms"
  task_definition = "${aws_ecs_task_definition.sms-docker-qa.arn}"
  cluster = "${aws_ecs_cluster.docker-QA-cl-rep.id}"
  desired_count = 1
}

resource "aws_ecs_service" "withdrawal" {
  name = "withdrawal"
  task_definition = "${aws_ecs_task_definition.withdrawal-docker-qa.arn}"
  cluster = "${aws_ecs_cluster.docker-QA-cl-rep.id}"
  desired_count = 1
}

resource "aws_ecs_service" "user-management" {
  name = "user-management"
  task_definition = "${aws_ecs_task_definition.user-management-docker-qa.arn}"
  cluster = "${aws_ecs_cluster.docker-QA-cl-rep.id}"
  desired_count = 0
}

resource "aws_ecs_service" "community" {
  name = "community"
  task_definition = "${aws_ecs_task_definition.community-docker-qa.arn}"
  cluster = "${aws_ecs_cluster.docker-QA-cl-rep.id}"
  desired_count = 1
}