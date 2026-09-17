data "aws_iam_policy_document" "assume" {
    statement {
        principals {
            type="Federated"
            identifiers=[var.oidc_provider_arn]
        }
        
        actions=["sts:AssumeRoleWithWebIdentity"]

        condition {
            test="StringEquals"
            variable="${replace(var.oidc_issuer,"https://","")}:aud"
            values=["sts.amazonaws.com"]
        }

        condition {
            test="StringEquals"
            variable="${replace(var.oidc_issuer,"https://","")}:sub"
            values=["system:serviceaccount:kube-system:aws-load-balancer-controller"]
        }
    }
}

resource "aws_iam_role" "this" {
    name="${var.name}-lb-controller"
    assume_role_policy=data.aws_iam_policy_document.assume.json
    tags=var.tags
}

resource "aws_iam_role_policy" "this" {
    name="${var.name}-lb-controller"
    role=aws_iam_role.this.id
    policy=jsonencode({
        Version="2012-10-17",
        Statement=[{
            Effect="Allow",
            Action=["ec2:Describe*",
            "elasticloadbalancing:Describe*",
            "elasticloadbalancing:CreateLoadBalancer",
            "elasticloadbalancing:CreateTargetGroup",
            "elasticloadbalancing:CreateListener",
            "elasticloadbalancing:DeleteLoadBalancer",
            "elasticloadbalancing:DeleteTargetGroup",
            "elasticloadbalancing:DeleteListener",
            "elasticloadbalancing:ModifyLoadBalancerAttributes",
            "elasticloadbalancing:ModifyTargetGroup",
            "elasticloadbalancing:ModifyTargetGroupAttributes",
            "elasticloadbalancing:RegisterTargets",
            "elasticloadbalancing:DeregisterTargets",
            "elasticloadbalancing:CreateRule",
            "elasticloadbalancing:ModifyRule",
            "elasticloadbalancing:SetWebAcl",
            "elasticloadbalancing:AddTags",
            "elasticloadbalancing:RemoveTags",
            "acm:DescribeCertificate",
            "acm:ListCertificates",
            "wafv2:GetWebACL",
            "wafv2:GetWebACLForResource",
            "wafv2:AssociateWebACL",
            "wafv2:DisassociateWebACL",
            "shield:GetSubscriptionState",
            "shield:DescribeProtection",
            "shield:CreateProtection",
            "shield:DeleteProtection",
            "iam:CreateServiceLinkedRole"],
            Resource="*"
        }]
    })
}