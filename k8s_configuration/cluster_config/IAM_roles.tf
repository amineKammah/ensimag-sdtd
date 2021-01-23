# Master Role
resource "aws_iam_role" "SDTD_master_role" {
  name = "k8s-cluster-iam-master-role"

  assume_role_policy = file("json_config/master_role_policy.json")
}
# Master Policy
resource "aws_iam_policy" "SDTD_master_policy" {
  name        = "k8s-cluster-iam-master-policy"

  policy = file("json_config/master_policy.json")
}

resource "aws_iam_role_policy_attachment" "test-attach-master" {
  role       = aws_iam_role.SDTD_master_role.name
  policy_arn = aws_iam_policy.SDTD_master_policy.arn
}

resource "aws_iam_instance_profile" "master_profile" {
  name = "k8s-cluster-iam-master-profile"
  role = aws_iam_role.SDTD_master_role.name
}
# Worker Role
resource "aws_iam_role" "SDTD_worker_role" {
  name = "k8s-cluster-iam-worker-role"

  assume_role_policy = file("json_config/worker_role_policy.json")
}
# Worker Policy
resource "aws_iam_policy" "SDTD_worker_policy" {
  name        = "k8s-cluster-iam-worker-policy"

  policy = file("json_config/worker_policy.json")
}

resource "aws_iam_role_policy_attachment" "test-attach-worker" {
  role       = aws_iam_role.SDTD_worker_role.name
  policy_arn = aws_iam_policy.SDTD_worker_policy.arn
}

resource "aws_iam_instance_profile" "worker_profile" {
  name = "k8s-cluster-iam-worker-profile"
  role = aws_iam_role.SDTD_worker_role.name
}